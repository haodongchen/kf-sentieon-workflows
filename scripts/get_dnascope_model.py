#!/usr/bin/env python3

import argparse
import yaml
import requests
import sys

def main():
    parser = argparse.ArgumentParser(description="Download DNAscope model bundle")
    parser.add_argument("model_name", help="the name of the model bundle, e.g. Illumina_WGS")
    args = parser.parse_args()
    model_name = args.model_name.split("-")
    sentieon_models_yaml = "https://raw.githubusercontent.com/Sentieon/sentieon-models/main/sentieon_models.yaml"
    response = requests.get(sentieon_models_yaml, allow_redirects=True)
    content = response.content.decode("utf-8")
    content = yaml.safe_load(content)
    try:
        url = content["DNAscope_bundles"][model_name[0]][model_name[1]]
        r = requests.get(url, allow_redirects=True)
        open(url.split("/")[-1], 'wb').write(r.content)
    except:
        open('empty.bundle', 'wb')
    print('Models updated on: ' + content["Updated on"], file=sys.stderr)

if __name__ == '__main__':
    main()

