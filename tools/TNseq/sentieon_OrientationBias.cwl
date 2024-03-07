cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_OrientationBias
doc: |-
  Run Sentieon OrientationBias tool.
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  - ``tumor_sample``: Tumor sample name
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``Quality recalibration table``: location of the quality recalibration table output from the BQSR stage.

$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu_per_job)
        {
            return inputs.cpu_per_job
        }
        else
        {
            return 32
        }
    }
  ramMin: |-
    ${
        if (inputs.mem_per_job)
        {
            return inputs.mem_per_job
        }
        else
        {
            return 32000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.02
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  inputBinding:
    prefix: -r
    position: 0
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: 
    type: array
    items: File
    inputBinding:
      prefix: -i
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    position: 1
  sbg:fileTypes: BAM, CRAM
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
  sbg:fileTypes: BED, VCF, interval_list
- id: tumor_sample
  label: Tumor sample name
  type: string
  inputBinding:
    prefix: --tumor_sample
    position: 11
- id: min_base_qual
  label: Minimum base quality
  type: int?
  inputBinding:
    prefix: --min_base_qual
    position: 15
  sbg:toolDefaultValue: '20'
- id: min_median_map_qual
  doc: Minimum median mapping quality for model training
  type: int?
  inputBinding:
    prefix: --min_median_map_qual
    position: 15
  sbg:toolDefaultValue: '50'
- id: max_depth
  label: Max depth
  doc: Depth larger than this value will be under the same group
  type: int?
  inputBinding:
    prefix: --max_depth
    position: 15
  sbg:toolDefaultValue: '200'
- id: output_file_name
  label: Output file name
  type: string
  inputBinding:
    position: 100
    valueFrom: |-
      $(self).tsv
- id: enable_tool
  type: boolean?
  doc: Should this tool be run? This option may only be used in a workflow
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: out_orient
  type: File
  outputBinding:
    glob: '*.tsv'
baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: OrientationBias
  shellQuote: false
