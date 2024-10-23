cwlVersion: v1.2
class: CommandLineTool
label: Download DNAscope model bundle
hints:
  - class: ResourceRequirement
    coresMin: 1
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: python:3.7-slim
  - class: InitialWorkDirRequirement
    listing:
      - entryname: get_dnascope_model.py
        entry:
          $include: ../scripts/get_dnascope_model.py
arguments:
  - prefix: 'pip'
    position: 0
    valueFrom: 'install pyyaml requests;'
    shellQuote: false
  - prefix: 'python'
    position: 1
    valueFrom: 'get_dnascope_model.py'
    shellQuote: false
inputs:
  - id: model_name
    label: Model name
    doc: Model platform and data type. For example, Illumina_WGS
    type: 
    - type: enum
      symbols:
        - Illumina-WGS
        - Illumina-WES
        - MGI-WGS
        - MGI-WES
        - Element_Biosciences-WGS
        - PacBio_HiFi-WGS
        - Oxford_Nanopore-WGS
    inputBinding:
      position: 2
outputs:
  - id: model_bundle
    label: DNAscope Model bundle
    type: File
    outputBinding:
      glob: '*.bundle'

