#!/usr/bin/env python3
"""
Download pangenome reference files if not provided by user.
Downloads from official HPRC and Sentieon repositories.
"""
import os
import sys
import urllib.request
from pathlib import Path


def download_file(url, output_path):
    """Download a file from URL to output_path"""
    print(f"Downloading {output_path} from {url}...")
    try:
        urllib.request.urlretrieve(url, output_path)
        print(f"Successfully downloaded {output_path}")
        return True
    except Exception as e:
        print(f"Error downloading {output_path}: {e}", file=sys.stderr)
        return False


def main():
    # Check which files are provided via command line arguments
    provided_files = sys.argv[1:] if len(sys.argv) > 1 else []

    downloads = [
        {
            'provided': 'hapl_file' in provided_files,
            'filename': 'hprc-v2.0-mc-grch38.hapl',
            'url': 'https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.hapl',
            'name': 'hapl file'
        },
        {
            'provided': 'gbz_file' in provided_files,
            'filename': 'hprc-v2.0-mc-grch38.gbz',
            'url': 'https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.gbz',
            'name': 'gbz file'
        },
        {
            'provided': 'pop_vcf' in provided_files,
            'filename': 'pop-v20g41-20251216.vcf.gz',
            'url': 'https://ftp.sentieon.com/public/GRCh38/population/pop-v20g41-20251216.vcf.gz',
            'name': 'population VCF',
        },
        {
            'provided': 'bed_file' in provided_files,
            'filename': 'hg38_canonical.bed',
            'url': 'https://ftp.sentieon.com/public/GRCh38/hg38_canonical.bed',
            'name': 'BED file'
        },
        {
            'provided': 'model_bundle' in provided_files,
            'filename': 'SentieonIlluminaPangenomeRealignWGS1.0.bundle',
            'url': 'https://s3.amazonaws.com/sentieon-release/other/SentieonIlluminaPangenomeRealignWGS1.0.bundle',
            'name': 'model bundle'
        }
    ]

    for item in downloads:
        if item['provided']:
            print(f"Using provided {item['name']}")
        else:
            if not download_file(item['url'], item['filename']):
                return 1

    print("All files ready")
    return 0


if __name__ == '__main__':
    sys.exit(main())
