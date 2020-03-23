import json
import sys


if len(sys.argv) >= 1:
    dcatfile = open(sys.argv[1])
    dcat = json.load(dcatfile)
    for ds in dcat['dataset']:
        if ds['distribution'][0]['format'] == "gitrepo":
            print(json.dumps(ds['distribution'][0]['downloadURL']))
