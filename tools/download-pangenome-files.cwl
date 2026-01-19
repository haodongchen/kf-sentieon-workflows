cwlVersion: v1.2
class: CommandLineTool
id: download_pangenome_files
label: Download Pangenome Reference Files
doc: |
  Downloads required pangenome reference files if not provided by the user.
  Files are downloaded from official HPRC and Sentieon repositories.

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'curlimages/curl:latest'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.hapl_file)
      - $(inputs.gbz_file)
      - $(inputs.pop_vcf)
      - $(inputs.bed_file)
      - $(inputs.model_bundle)
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 2

baseCommand: [bash, -c]
arguments:
  - valueFrom: |
      set -eo pipefail

      # Download hapl file if not provided
      if [ ! -f "$(inputs.hapl_file ? inputs.hapl_file.basename : 'none')" ]; then
        echo "Downloading hapl file..."
        curl -L -o hprc-v2.0-mc-grch38.hapl https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.hapl
      else
        echo "Using provided hapl file"
      fi

      # Download gbz file if not provided
      if [ ! -f "$(inputs.gbz_file ? inputs.gbz_file.basename : 'none')" ]; then
        echo "Downloading gbz file..."
        curl -L -o hprc-v2.0-mc-grch38.gbz https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.gbz
      else
        echo "Using provided gbz file"
      fi

      # Download pop_vcf if not provided
      if [ ! -f "$(inputs.pop_vcf ? inputs.pop_vcf.basename : 'none')" ]; then
        echo "Downloading population VCF..."
        curl -L -o pop-v20g41-20251216.vcf.gz https://ftp.sentieon.com/public/GRCh38/population/pop-v20g41-20251216.vcf.gz
      else
        echo "Using provided population VCF"
      fi

      # Download bed file if not provided
      if [ ! -f "$(inputs.bed_file ? inputs.bed_file.basename : 'none')" ]; then
        echo "Downloading BED file..."
        curl -L -o hg38_canonical.bed https://ftp.sentieon.com/public/GRCh38/hg38_canonical.bed
      else
        echo "Using provided BED file"
      fi

      # Download model bundle if not provided
      if [ ! -f "$(inputs.model_bundle ? inputs.model_bundle.basename : 'none')" ]; then
        echo "Downloading model bundle..."
        curl -L -o SentieonIlluminaPangenomeRealignWGS1.0.bundle https://s3.amazonaws.com/sentieon-release/other/SentieonIlluminaPangenomeRealignWGS1.0.bundle
      else
        echo "Using provided model bundle"
      fi

inputs:
  hapl_file:
    type: File?
    doc: Optional hapl file; if not provided, will download hprc-v2.0-mc-grch38.hapl

  gbz_file:
    type: File?
    doc: Optional gbz file; if not provided, will download hprc-v2.0-mc-grch38.gbz

  pop_vcf:
    type: File?
    doc: Optional population VCF; if not provided, will download pop-v20g41-20251216.vcf.gz

  bed_file:
    type: File?
    doc: Optional BED file; if not provided, will download hg38_canonical.bed

  model_bundle:
    type: File?
    doc: Optional model bundle file; if not provided, will download SentieonIlluminaPangenomeRealignWGS1.0.bundle

outputs:
  hapl_file_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.hapl_file) {
            return inputs.hapl_file.basename;
          } else {
            return "hprc-v2.0-mc-grch38.hapl";
          }
        }
    doc: Hapl file (provided or downloaded)

  gbz_file_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.gbz_file) {
            return inputs.gbz_file.basename;
          } else {
            return "hprc-v2.0-mc-grch38.gbz";
          }
        }
    doc: GBZ file (provided or downloaded)

  pop_vcf_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.pop_vcf) {
            return inputs.pop_vcf.basename;
          } else {
            return "pop-v20g41-20251216.vcf.gz";
          }
        }
    doc: Population VCF (provided or downloaded)

  bed_file_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.bed_file) {
            return inputs.bed_file.basename;
          } else {
            return "hg38_canonical.bed";
          }
        }
    doc: BED file (provided or downloaded)

  model_bundle_out:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.model_bundle) {
            return inputs.model_bundle.basename;
          } else {
            return "SentieonIlluminaPangenomeRealignWGS1.0.bundle";
          }
        }
    doc: Model bundle file (provided or downloaded)
