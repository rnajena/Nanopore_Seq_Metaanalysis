#!/usr/bin/env python

"""
author: Daria Meyer
contact:daria.meyer@uni-jena.de
created: 06.03.2024

Goal: Extract metainformation from multiple nanopore sequencing runs
Example: python get_metadata.py --infolder /data/fass5/projects/dm_bitsNpieces_ONT/metadata/r9data/runs
"""

import os
import os.path
import argparse
import numpy as np
import pandas as pd

# Instantiate the parser
parser = argparse.ArgumentParser(description='Extract metadate from nanopore sequencing runs from all subfolders')
parser.add_argument('--infolder', help='Given input folder (absolute path) which contains data for multiple sequencing runs with one folder containing data for one run.')
args = parser.parse_args()
infolder = args.infolder

## Extract a list with all direct subfolders. Each folder should contain data from one sequencing run.
dataFolders =  [f.path for f in os.scandir(infolder) if f.is_dir() ]
# print(dataFolders)

runFolder = dataFolders[0]

# print(f"Analyzing folder {runFolder}")

# for dirpath, dirnames, filenames in os.walk(infolder):
#     for filename in [f for f in filenames if f.startswith("final_summary")]:
#         print(os.path.join(dirpath, filename))

def getDateFromSummary(finalSummary : str) -> str:
    with open(finalSummary, 'r') as r:
        for line in r:
            if line.startswith('started'):
                return line.strip().split('=')[1].split('T')[0]

def getRunIdFromSummary(finalSummary : str) -> str:
    with open(finalSummary, 'r') as r:
        for line in r:
            if line.startswith('acquisition_run_id'):
                return line.strip().split('=')[1]

def getFcIdFromSummary(finalSummary : str) -> str:
    with open(finalSummary, 'r') as r:
        for line in r:
            if line.startswith('flow_cell_id'):
                return line.strip().split('=')[1]

def getSampleIdFromSummary(finalSummary : str) -> str:
    with open(finalSummary, 'r') as r:
        for line in r:
            if line.startswith('sample_id'):
                return line.strip().split('=')[1]

def getEstBasesFromThroughput(throughput : str) -> str:
	with open(throughput, 'r') as r:
		firstLine = r.readline().split(',')
		pos = firstLine.index("Estimated Bases")
		return r.readlines()[-1].split(',')[pos]

def getRunIdFromReport(report : str) -> str:
    with open(report, 'r') as r:
        for line in r:
            if '\"run_id\"' in line:
                # print(line.strip().split(':')[1].split('"')[1])
                return line.strip().split(':')[1].split('"')[1]

def getFcIdFromReport(report : str) -> str:
    with open(report, 'r') as r:
        for line in r:
            if '\"flow_cell_id\"' in line:
                # print(line.strip().split(':')[1].split('"')[1])
                return line.strip().split(':')[1].split('"')[1]

def getSampleIdFromReport(report : str) -> str:
    with open(report, 'r') as r:
        for line in r:
            if '\"sample_id\"' in line:
                # print(line.strip().split(':')[1].split('"')[1])
                return line.strip().split(':')[1].split('"')[1]


def getDateFromReport(report : str) -> str:
    with open(report, 'r') as r:
        for line in r:
            if '\"exp_start_time\"' in line:
                # print(line.strip().split(':')[1].split('"')[1])
                return line.strip().split(':')[1].split('"')[1].split("T")[0]

def getActivePoresFromMuxScan(muxScan : str) -> str:
	muxData = pd.read_csv(muxScan, sep = ',', header = 0, nrows = 5000) ## First measurement should only be 2048 lines
	## get all included wells from the first repeat (= first mux scan)
	try:
		return muxData.loc[(muxData['repeat']==1) & (muxData['include_well']==1)].shape[0]
	except:
		## Weird version with scan_number instead of repeat in mux_scan data
		return muxData.loc[(muxData['scan_number']==1) & (muxData['include_well']==1)].shape[0]

def getActivePoresFromPoreScan(poreScan : str) -> str:
	poreData = pd.read_csv(poreScan, sep = ',', header = 0, nrows = 5000) ## First measurement should only be 2048 lines
	## get all included wells from the first repeat (= first mux scan)
	return poreData.loc[(poreData['scan_number']==1) & (poreData['include_well']==1)].shape[0]

def getActiveChannelsFromDriftCorrection(driftCorrection : str) -> str:
	with open(driftCorrection, 'r') as infile:
		## drift correction contains number of active channels over time. First line contains first measurement
		pos = infile.readline().split(',').index('n_channels')
		return infile.readline().split(',')[pos]

def getActiveChannelsFromSeqSummary(seqSummary : str) -> str:
	# print("Reading input file...")
	numrows = 500000
	maxtime = 0
	seq_summary = pd.read_csv(seqSummary, delimiter='\t', usecols=['channel', 'start_time'], nrows = numrows)
	# print("Max time before while:")
	# print(seq_summary.max(axis = 'index')['start_time'])
	if (seq_summary.max(axis = 'index')['start_time'] < 3600):
		## Increase the amount of used data, until data from nearly one hour exists
		while(numrows < 5000000 and maxtime < 3600):
			numrows += 500000
			seq_summary = pd.read_csv(seqSummary, delimiter='\t', usecols=['channel', 'start_time'], nrows = numrows)
			maxtime = seq_summary.max(axis = 'index')['start_time']
	## Even if while loop is left, the maximum number of channels from the read data is reported
	return(len(seq_summary.loc[(seq_summary['start_time']<=3600)]['channel'].unique()))

	# # ensure the file is sorted by time and reset its
	# # indexing after doing so
	# seq_summary.sort_values('start_time', inplace=True)
	# seq_summary.reset_index(drop=True, inplace=True)
	# seq_summary = seq_summary
	# print("Done.")
	# # calculate a start time for each read rounded to discretize minutes
	# seq_summary['time'] = (seq_summary['start_time'] / 60 ).astype(int)
	# # group the data by quarter hour
	# groups = seq_summary.groupby('time', as_index=False)
	# # count the unique channels in each 5 minutes
	# chan_counts = groups['channel'].apply(lambda x: len(x.unique()))

## Initiate all needed parameters
runId = ""
runId_report = ""
fcId = ""
fcId_report = ""
startDate = ""
startDate_report = ""
sampleId = ""
estBases = 0
activePores = 0
activeChannels = ""

# print(f"runId\tfcId\tstartDate\testBases")
# results = [["runID", "fcID", "startDate", "estBases"]]
results = []

for runFolder in dataFolders:
	summaryExists = False
	throughputExists = False
	for dirpath, dirnames, filenames in os.walk(runFolder):
		for filename in filenames:

			## Extract runId, FcId, startData, sampleId from final summary
			if filename.startswith("final_summary"):
				finalSummary = os.path.join(dirpath, filename)
				runId = getRunIdFromSummary(finalSummary)
				fcId = getFcIdFromSummary(finalSummary)
				startDate = getDateFromSummary(finalSummary)
				sampleId = getSampleIdFromSummary(finalSummary)

			## Extract number of estimated bases from throughput
			elif filename.startswith("throughput"):
				throughput = os.path.join(dirpath, filename)
				try:
					estBases = getEstBasesFromThroughput(throughput)	
				except:
					print(f"No estimated bases in file {filename} in {runFolder}")
			## Extract runId, fcID, startDate from report file
			elif filename.startswith("report") and filename.endswith(".md"):
				report = os.path.join(dirpath, filename)
				runId_report = getRunIdFromReport(report)
				fcId_report = getFcIdFromReport(report)
				startDate_report = getDateFromReport(report)
				sampleId_report = getSampleIdFromReport(report)

			elif filename.startswith("mux_scan_data"):
				muxScan = os.path.join(dirpath, filename)
				activePores = getActivePoresFromMuxScan(muxScan)

			elif filename.startswith("pore_scan_data"):
				poreScan = os.path.join(dirpath, filename)
				activePores = getActivePoresFromPoreScan(poreScan)

			elif filename.startswith("pore_scan_data"):
				poreScan = os.path.join(dirpath, filename)
				activePores = getActivePoresFromPoreScan(poreScan)

			elif filename.startswith("drift_correction"):
				driftCorrection = os.path.join(dirpath, filename)
				activeChannels = getActiveChannelsFromDriftCorrection(driftCorrection)

			elif(filename.startswith("sequencing_summary")):
				seqSummary = os.path.join(dirpath, filename)
				activeChannels_seqSummary = getActiveChannelsFromSeqSummary(seqSummary)

	## Use data from report file if final summary does not exist
	if(runId == None):
		runId = runId_report
	if(fcId == None):
		fcId = fcId_report
	if(startDate == None):
		startDate = startDate_report
	if(sampleId == None):
		sampleId = sampleId_report
	if(activeChannels == None):
		activeChannels = activeChannels_seqSummary
	
	## Add all metadata for this run into a results file
	results.append([runId, fcId, startDate, estBases, activePores, activeChannels, sampleId])
	# print(f"{runId}\t{fcId}\t{startDate}\t{estBases}")

## Output all metadata to file
with open('metadataExtraced.tsv', 'a') as f:
	f.write(f"runId\tfcId\tstartDate\testBases\tactivePores\tactiveChannels\tsampleId\n")
	for run in results:
		for value in run:
			f.write(f"{value}\t")
		f.write(f"\n")

