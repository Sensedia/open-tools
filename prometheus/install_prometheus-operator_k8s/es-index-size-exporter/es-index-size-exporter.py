#Prometheus exporter to get size of group of indices and document count of them.
#The scripts is a different from elasticsearch_exporter because they summarize data to give a unique metric for a group of indices (defined by the regex). This work's better for time series data of specific ranges

from prometheus_client import start_http_server, Metric, REGISTRY
import json
import requests
import sys
import time
import os
import re

#Define values
port = 9099
endpoint = os.getenv('es.endpoint', "localhost:9200")
indicesPattern = os.getenv('es.index.pattern', "(.*-metrics).*")

print "Starting collector at port",port
print "Endpoint ES: ",endpoint
print "Regex to search: ",indicesPattern

#endpoint = 

#Function to summarize indices names based on regex

#Start functionts
def collectIndicesGroupSizes(indicesGroups,json_data,indicesPattern):
	#create the dict
	indicesGroupSizes = {}

	#Parser the json
	jsonIndices = json.loads(json_data)


	#Let run the indicesGroups list and find value for each index entry and sum all of then
	for indiceGroup in indicesGroups:
	
		#Let's create a counter to sum all indice size values
		counter = 0

		#Let's run the json, looking for each indice group
		for indice in jsonIndices:
		
			#Check if indiceGroup is in the indice at json AND if indice at json matchs if the indicesPattern (to make sure that we are getting only the rigth values) 
			if indiceGroup in indice['index'] and re.search(indicesPattern, indice['index'], re.IGNORECASE) is not None:
				counter += int(indice['store.size'])

		#Let's save this indiceGroup and value on the dict indicesGroupSizes, but only if it not exist yet
		if indiceGroup not in indicesGroupSizes.keys():
			indicesGroupSizes[indiceGroup] = counter 

	return indicesGroupSizes 

def summarizeIndices(json_data,indicesPattern):
	#create an empty list
	indicesGroups = []
	
	#Parser json file
	for indice in json.loads(json_data):
		#check if the indice name match with regex. To do that, we will first try match the regex:
		indice_search = re.search(indicesPattern, indice['index'], re.IGNORECASE)

		#If we found it, we will check if they already exist in indicesGroups. If not, we will append group 1 at indicesGroup list.
		if indice_search is not None:
			if indice_search.group(1) not in indicesGroups:
				indicesGroups.append(indice_search.group(1))

	return indicesGroups


#Start classe collector
class JsonCollector(object):
	def __init__(self, endpoint):
		self._endpoint = endpoint

	def collect(self):
		# Fetch the JSON
		#response = json.loads(requests.get(self._endpoint).content.decode('UTF-8'))
		# fetch json from file
		json_data=open("./indices").read()

		#This function will summarize each index pattern. The return would be a list with each indice group 
		#For example, for a group of indice called customer-metrics-*, a regex like '(.*-metrics).*' will return 'customer-metrics'
		indicesGroups = summarizeIndices(json_data,indicesPattern)

		#Call the function sum the total size in bytes of each indiceGroup. The return will be a dict with 1st group of match and they values
		indicesGroupSizes = collectIndicesGroupSizes(indicesGroups,json_data,indicesPattern)

		#Metric es_group_indices_size
		metric = Metric('es_group_indices_size','Size of a group of indices','gauge')
		#Run the indicesGroupSizes dict and add those infos at metric 
		for labelValue,sizeValue in indicesGroupSizes.items():
			metric.add_sample('es_group_indices_size',value=sizeValue,labels={'group':labelValue})

		#Exporse the metric
		yield metric 
		#/Metric es_group_indices_size
			
if __name__ == '__main__':
	# Usage: json_exporter.py port endpoint
	start_http_server(port)

	REGISTRY.register(JsonCollector(endpoint))

	while True: time.sleep(1)
