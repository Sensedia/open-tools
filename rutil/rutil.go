package main

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"github.com/mediocregopher/radix.v2/cluster"
	"github.com/mediocregopher/radix.v2/redis"
	"io"
	"os"
	"regexp"
)

type rutil struct {
	Host      string
	Port      int
	Auth      string
	isCluster bool
	cli       *redis.Client
	cluster   *cluster.Cluster
}

type KeyDump struct {
	Key   []byte
	KeyL  uint64
	Dump  []byte
	DumpL uint64
	Pttl  int64
}

type FileHeader struct {
	Magic   [4]byte
	Version uint8
	Keys    uint64
}

func (r *rutil) Cluster() *cluster.Cluster {
	if r.cluster == nil {
		cluster, err := cluster.New("")
		checkErr(err, "CONNECT "+fmt.Sprintf("%s:%d"))

		if r.Auth != "" {
			res := cluster.Cmd("AUTH", r.Auth)
			checkErr(res.Err, "AUTH")
		}
		r.cluster = cluster
	}
	return r.cluster
}

func (r *rutil) Client() *redis.Client {
	if r.cli == nil {
		cli, err := redis.Dial("tcp", fmt.Sprintf("%s:%d", r.Host, r.Port))
		checkErr(err, "CONNECT "+fmt.Sprintf("%s:%d"))
		if r.Auth != "" {
			res := cli.Cmd("AUTH", r.Auth)
			checkErr(res.Err, "AUTH")
		}
		r.cli = cli
	}
	return r.cli
}

func (r *rutil) getKeys(wcard string, regex string, invert bool) ([]string, int) {
	var res *redis.Resp
	if r.isCluster {
		res = r.Cluster().Cmd("KEYS", wcard)
	} else {
		res = r.Client().Cmd("KEYS", wcard)
	}

	checkErr(res.Err, "KEYS "+wcard)
	l, err := res.List()
	checkErr(err, "KEYS "+wcard+" res.List()")
	vsf := make([]string, 0)
	for _, v := range l {
		if invertibleMatch(v, regex, invert) {
			vsf = append(vsf, v)
		}
	}

	return vsf, len(vsf)
}

func invertibleMatch(s string, r string, v bool) bool {
	if r == "" {
		return true
	}
	m, _ := regexp.MatchString(r, s)
	if v {
		return !m
	} else {
		return m
	}
}

func (r *rutil) dumpKey(k string) (bool, KeyDump) {
	d := KeyDump{
		Key:  []byte(k),
		KeyL: uint64(len(k)),
	}
	var err interface{}

	var res *redis.Resp
	if r.isCluster {
		res = r.Cluster().Cmd("PTTL", k)
	} else {
		res = r.Client().Cmd("PTTL", k)
	}

	checkErr(res.Err, "PTTL "+k)
	d.Pttl, err = res.Int64()
	if d.Pttl == -2 {
		fmt.Printf("EXPIRED: %s\n", k)
		return false, d
	} else if d.Pttl == -1 {
		d.Pttl = 0
	}
	checkErr(err, "PTTL "+k+" res.Int64()")

	if r.isCluster {
		res = r.Cluster().Cmd("DUMP", k)
	} else {
		res = r.Client().Cmd("DUMP", k)
	}

	checkErr(res.Err, "DUMP "+k)
	d.Dump, err = res.Bytes()
	checkErr(err, "DUMP "+k+" res.Bytes()")
	d.DumpL = uint64(len(d.Dump))

	return true, d
}

func (r *rutil) writeHeader(f io.Writer, keys_c int) int {
	h := FileHeader{
		Magic:   [4]byte{0x52, 0x44, 0x4d, 0x50},
		Version: uint8(0x01),
		Keys:    uint64(keys_c),
	}

	checkErr(binary.Write(f, binary.BigEndian, h), "writeHeader")
	return binary.Size(h)
}

func (r *rutil) readHeader(f io.Reader) FileHeader {
	var h FileHeader
	binary.Read(f, binary.BigEndian, &h)
	return h
}

func (r *rutil) writeDump(f io.Writer, d KeyDump) int {
	size := binary.Size(d.Pttl) +
		binary.Size(d.KeyL) +
		binary.Size(d.Key) +
		binary.Size(d.DumpL) +
		binary.Size(d.Dump)

	checkErr(binary.Write(f, binary.BigEndian, d.Pttl), "write d.Pttl")
	checkErr(binary.Write(f, binary.BigEndian, d.KeyL), "write d.KeyL")
	checkErr(binary.Write(f, binary.BigEndian, d.Key), "write d.Key")
	checkErr(binary.Write(f, binary.BigEndian, d.DumpL), "write d.DumpL")
	checkErr(binary.Write(f, binary.BigEndian, d.Dump), "write d.Dump")
	return size
}

func (r *rutil) readDump(f io.Reader) (bool, KeyDump) {
	var d KeyDump

	err := binary.Read(f, binary.BigEndian, &d.Pttl)
	checkErr(err, "binary.Read d.Pttl")
	err = binary.Read(f, binary.BigEndian, &d.KeyL)
	checkErr(err, "binary.Read d.KeyL")
	d.Key = make([]byte, d.KeyL)
	err = binary.Read(f, binary.BigEndian, &d.Key)
	checkErr(err, "binary.Read d.Key")
	err = binary.Read(f, binary.BigEndian, &d.DumpL)
	checkErr(err, "binary.Read d.DumpL")
	d.Dump = make([]byte, d.DumpL)
	err = binary.Read(f, binary.BigEndian, &d.Dump)
	checkErr(err, "binary.Read d.Dump")

	return false, d
}

func (r *rutil) restoreKey(d KeyDump, del bool, ignor bool) int {
	var res *redis.Resp

	if del {
		if r.isCluster {
			res = r.Cluster().Cmd("DEL", d.Key)
		} else {
			res = r.Client().Cmd("DEL", d.Key)
		}

		checkErr(res.Err, "DEL "+string(d.Key))
	}

	if r.isCluster {
		res = r.Cluster().Cmd("RESTORE", d.Key, d.Pttl, d.Dump)
	} else {
		res = r.Client().Cmd("RESTORE", d.Key, d.Pttl, d.Dump)
	}

	if ignor == true {
		if res.Err != nil {
			return 0
		} else {
			return 1
		}
	} else {
		checkErr(res.Err, "RESTORE "+string(d.Key))
		return 1
	}
}

func (r *rutil) printKey(key string, fld []string, json bool) {
	var res *redis.Resp

	if r.isCluster {
		res = r.Cluster().Cmd("TYPE", key)
	} else {
		res = r.Client().Cmd("TYPE", key)
	}

	checkErr(res.Err, "TYPE "+key)
	key_t, err := res.Str()
	checkErr(err, "TYPE "+key+" res.Str()")

	fmt.Printf("KEY: %s\nTYP: %s\n", key, key_t)
	switch key_t {
	case "set":
		if r.isCluster {
			res = r.Cluster().Cmd("SMEMBERS", key)
		} else {
			res = r.Client().Cmd("SMEMBERS", key)
		}
		checkErr(res.Err, "SMEMBERS"+key)
		set, err := res.List()
		checkErr(err, "SMEMBERS "+key+" res.List()")
		fmt.Println("VAL:", set, "\n")
	case "hash":
		if len(fld) == 0 {
			if r.isCluster {
				res = r.Cluster().Cmd("HGETALL", key)
			} else {
				res = r.Client().Cmd("HGETALL", key)
			}
			checkErr(res.Err, "HGETALL "+key)
			hash, err := res.Map()
			checkErr(err, "HGETALL "+key+" res.Map()")
			ppHash(hash, json)
		} else {
			if r.isCluster {
				res = r.Cluster().Cmd("HMGET", key, fld)
			} else {
				res = r.Client().Cmd("HMGET", key, fld)
			}
			checkErr(res.Err, "HMGET "+key)
			arr, err := res.List()
			checkErr(err, "HMGET "+key+" res.List()")
			hash := map[string]string{}
			for i, k := range fld {
				hash[k] = arr[i]
			}
			ppHash(hash, json)
		}
	case "string":
		if r.isCluster {
			res = r.Cluster().Cmd("GET", key)
		} else {
			res = r.Client().Cmd("GET", key)
		}
		checkErr(res.Err, "GET "+key)
		str, err := res.Str()
		checkErr(err, "GET "+key+" res.Str()")
		ppString(str, json)
	case "zset":
		if r.isCluster {
			res = r.Cluster().Cmd("ZRANGE", key, 0, -1)
		} else {
			res = r.Client().Cmd("ZRANGE", key, 0, -1)
		}
		checkErr(res.Err, "ZRANGE "+key)
		set, err := res.List()
		checkErr(err, "ZRANGE "+key+" res.List()")
		fmt.Println("VAL:", set, "\n")
	case "list":
		if r.isCluster {
			res = r.Cluster().Cmd("LRANGE", key, 0, -1)
		} else {
			res = r.Client().Cmd("LRANGE", key, 0, -1)
		}
		checkErr(res.Err, "LRANGE "+key)
		list, err := res.List()
		checkErr(err, "LRANGE "+key+" res.List()")
		fmt.Println("VAL:", list, "\n")
	default:
		fail(key_t)
	}
}

func ppString(s string, j bool) {
	if j {
		var b interface{}
		err := json.Unmarshal([]byte(s), &b)
		if err != nil {
			fmt.Println("VAL:", s, "\n")
		} else {
			out, _ := json.MarshalIndent(b, "", "\t")
			fmt.Println(string(out), "\n")
		}
	} else {
		fmt.Println("VAL:", s, "\n")
	}
}

func ppHash(h map[string]string, j bool) {
	hh := make(map[string]interface{})
	for k, v := range h {
		if j {
			var b interface{}
			err := json.Unmarshal([]byte(v), &b)
			if err != nil {
				hh[k] = v
			} else {
				hh[k] = b
			}
		} else {
			hh[k] = v
		}
	}

	out, _ := json.MarshalIndent(hh, "", "\t")
	fmt.Println(string(out), "\n")
}

func fail(message string) {
	fmt.Fprintf(os.Stderr, "ERROR: %s\n", message)
	os.Exit(1)
}

func checkErr(err interface{}, action string) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: %s at %s\n", err, action)
		os.Exit(1)
	}
}

func genRespProto(a ...interface{}) {
	fmt.Printf("*%d\r\n", len(a))
	for _, e := range a {
		switch v := e.(type) {
		case string:
			fmt.Printf("$%d\r\n%s\r\n", len(v), v)
		case []byte:
			fmt.Printf("$%d\r\n%s\r\n", len(v), v)
		case int64:
			fmt.Printf("$%d\r\n%d\r\n", len(fmt.Sprintf("%d", v)), v)
		default:
			fail("error generating redis resp proto")
		}
	}
}
