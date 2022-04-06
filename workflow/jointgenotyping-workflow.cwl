cwlVersion: v1.2
class: Workflow
label: Sentieon Distributed Joint Genotyping Workflow

requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  sbg:fileTypes: FA, FASTA
- id: input_vcfs
  label: Input GVCFs
  type:
    type: array
    inputBinding:
      position: 0
      shellQuote: true
    items: File
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  sbg:fileTypes: VCF, VCF.GZ, GVCF, GVCF.GZ
- id: dbSNP
  label: dbSNP VCF file
  doc: |-
    Supplying this file will annotate variants with their dbSNP refSNP ID numbers. (optional)
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: size_of_chunks
  label: The size of each chunk (MB). We recommend using 100 MB bases as the shard size.
  type: int?
  sbg:exposed: true
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".vcf.gz".
  type: string?
  sbg:exposed: true

outputs:
- id: output_vcf
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputSource:
  - sentieon_gvcftyper_merge/output_vcf
  sbg:fileTypes: VCF.GZ

steps:
- id: generate_shards
  label: generate_shards
  in:
  - id: reference
    source: reference
  - id: size_of_chunks
    source: size_of_chunks
  run: ../tools/generate_shards.cwl
  out:
  - id: output
- id: sentieon_gvcftyper_distributed 
  label: Sentieon_GVCFtyper_Distributed 
  in:
  - id: sentieon_license
    source: sentieon_license
  - id: reference
    source: reference
  - id: advanced_driver_options
    source: generate_shards/output
  - id: input_vcfs
    source:
    - input_vcfs
  - id: dbSNP
    source: dbSNP
  scatter:
  - advanced_driver_options
  scatterMethod: dotproduct
  run: ../tools/sentieon_gvcftyper.cwl
  out:
  - id: output_vcf
- id: sentieon_gvcftyper_merge
  label: Sentieon_GVCFtyper_Merge
  in:
  - id: sentieon_license
    source: sentieon_license
  - id: reference
    source: reference
  - id: advanced_driver_options
    default: --passthru
  - id: input_vcfs
    source:
    - sentieon_gvcftyper_distributed/output_vcf
  - id: advanced_algo_options
    default:
    - --merge
  - id: output_file_name
    source: output_file_name
    default: joint_final.vcf.gz
  - id: cpu_per_job
    default: 2
  run: ../tools/sentieon_gvcftyper.cwl
  out:
  - id: output_vcf
