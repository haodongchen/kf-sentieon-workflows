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
    dockerPull: 'python:3.7-slim'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.hapl_file)
      - $(inputs.gbz_file)
      - $(inputs.pop_vcf)
      - $(inputs.bed_file)
      - $(inputs.model_bundle)
      - entryname: download_pangenome_files.py
        entry:
          $include: ../scripts/download_pangenome_files.py
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 2

baseCommand: [python3, download_pangenome_files.py]
arguments:
  - valueFrom: |
      ${
        var provided = [];
        if (inputs.hapl_file) provided.push('hapl_file');
        if (inputs.gbz_file) provided.push('gbz_file');
        if (inputs.pop_vcf) provided.push('pop_vcf');
        if (inputs.bed_file) provided.push('bed_file');
        if (inputs.model_bundle) provided.push('model_bundle');
        return provided.join(' ');
      }
    shellQuote: false

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
