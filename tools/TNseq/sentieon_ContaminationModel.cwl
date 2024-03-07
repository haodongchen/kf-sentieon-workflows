cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_ContaminationModel
doc: |-
  Run Sentieon ContaminationModel tool.
  
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
- id: normal_sample
  label: Normal sample name
  type: string?
  inputBinding:
    prefix: --normal_sample
    position: 12
- id: min_map_qual
  label: Minimum mapping quality
  type: int?
  inputBinding:
    prefix: --min_map_qual
    position: 15
  sbg:toolDefaultValue: '50'
- id: vcf
  label: Common variant VCF
  doc: Common population variant VCF file
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: --vcf
    position: 15
- id: min_af
  label: Minimum AF
  doc: Minimum population allele frequency
  type: float?
  inputBinding:
    prefix: --min_af
    position: 15  
  sbg:toolDefaultValue: '0.01'
- id: max_af
  label: Maximum AF
  doc: Maximum population allele frequency
  type: float?
  inputBinding:
    prefix: --max_af
    position: 15  
  sbg:toolDefaultValue: '0.2'
- id: output_file_name
  label: Output file name
  type: string
  inputBinding:
    position: 100
    valueFrom: |-
      $(self).tsv
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: output_contamination
  type: File
  outputBinding:
    glob: '*.tsv'
- id: tumor_segments
  type: File
  outputBinding:
    glob: '*.segments'
baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: ContaminationModel
  shellQuote: false
- prefix: '--tumor_segments'
  position: 50
  valueFrom: $(inputs.output_file_name).segments
