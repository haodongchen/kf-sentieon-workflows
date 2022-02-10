cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_CoverageMetrics
doc: |-
  Run Sentieon QC tools.
  This tool performs the following QC tasks:
  CoverageMetrics
  
  | Sentieon tool               	| GATK pipeline tool   	| Description                                                       	|
  |-----------------------------	|----------------------	|--------------------------------------------------------------------	|
  | CoverageMetrics              	| DepthOfCoverage      	| calculates the depth coverage of the BAM file                      	|
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``Quality recalibration table``: location of the quality recalibration table output from the BQSR stage.
  #### Optional for ``CoverageMetrics``
  - ``Gene list``: location of the RefSeq file used to aggregate the results of the CoverageMetrics algorithm to the gene level.

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
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
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
    required: true
  inputBinding:
    prefix: -r
    position: 0
    shellQuote: false
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
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
    prefix: -i
    position: 1
    shellQuote: false
  sbg:fileTypes: BAM, CRAM
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: false
  sbg:fileTypes: BED, VCF, interval_list
- id: recal_table
  label: Quality recalibration table
  doc: |-
    Location of the quality recalibration table output from the BQSR stage. 
    Do not use this option if the input BAM has already been recalibrated.
  type: File?
  inputBinding:
    prefix: -q
    position: 2
    shellQuote: false
- id: gene_list
  label: Gene list
  doc: |-
    location of the RefSeq file used to aggregate the results of the CoverageMetrics algorithm to the gene level.
  type: File?
  inputBinding:
    prefix: --gene_list
    position: 15
    shellQuote: false
- id: min_map_qual
  label: Min map qual
  doc: |-
    Minimum mapping quality (default: -1)
  type: int?
  default: -1
  inputBinding:
    prefix: --min_map_qual
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '-1'
- id: max_map_qual
  label: Max map qual
  doc: |-
    Maximum mapping quality (default: 2147483647)
  type: int?
  default: 2147483647
  inputBinding:
    prefix: --max_map_qual
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '2147483647'
- id: min_base_qual
  label: Min base qual
  doc: |-
    Minimum base quality (default: -1)
  type: int?
  default: -1
  inputBinding:
    prefix: --min_base_qual
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '-1'
- id: max_base_qual
  label: Max base qual
  doc: |-
    Maximum base quality (default: 127)
  type: int?
  default: 127
  inputBinding:
    prefix: --max_base_qual
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '127'
- id: count_type
  label: Count type
  doc: |-
    Count type for overlapping reads (default: 0)
    * 0: to count overlapping reads even if they come from the same fragment. This is the default value.
    * 1: to count overlapping reads
    * 2: to count overlapping reads only if the reads in the fragment have consistent bases.
  type: int?
  default: 0
  inputBinding:
    prefix: --count_type
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '0'
- id: histogram_low
  label: Histogram low
  doc: |-
    Histogram lowest depth (default: 1)
  type: int?
  default: 1
  inputBinding:
    prefix: --histogram_low
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '1'
- id: histogram_high
  label: Histogram high
  doc: |-
    Histogram highest depth (default: 500)
  type: int?
  default: 500
  inputBinding:
    prefix: --histogram_high
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '500'
- id: histogram_bin_count
  label: Histogram bin count
  doc: |-
    Histogram bin count for depth (default: 499)
  type: int?
  default: 499
  inputBinding:
    prefix: --histogram_bin_count
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: '499'
- id: histogram_scale
  label: Histogram scale
  doc: |-
    Histogram bin value scale: log or linear (default: log)
  type:
  - 'null'
  - name: histogram_scale
    type: enum
    symbols:
    - 'log'
    - 'linear'
  default: 'log'
  inputBinding:
    prefix: --histogram_scale
    position: 15
    shellQuote: false
  sbg:toolDefaultValue: 'log'
- id: cov_thresh
  label: Coverage threshold
  doc: |-
    Percent coverage threshold in statistics
  type:
  - 'null'
  - type: array
    items: string
    inputBinding:
      separate: true
      prefix: --cov_thresh
  inputBinding:
    position: 15
    shellQuote: false
- id: partition
  label: Partition
  doc: |-
    Partition: readgroup or comma separated combination of sample, platform, library, center (default: sample)
  type:
  - 'null'
  - type: array
    items: string
    inputBinding:
      separate: true
      prefix: --partition
  inputBinding:
    position: 15
    shellQuote: false
- id: print_base_counts
  label: Print base counts
  doc: |-
    Print base counts to per-locus output
  type: boolean?
  inputBinding:
    prefix: --print_base_counts
    position: 15
    shellQuote: false
- id: omit_base_output
  label: Omit base output
  doc: |-
    Skip output at each base
  type: boolean?
  inputBinding:
    prefix: --omit_base_output
    position: 15
    shellQuote: false
- id: omit_locus_stat
  label: Omit locus statistics
  doc: |-
    Skip statistics per locus
  type: boolean?
  inputBinding:
    prefix: --omit_locus_stat
    position: 15
    shellQuote: false
- id: omit_interval_stat
  label: Omit interval statistics
  doc: |-
    Skip statistics per interval
  type: boolean?
  inputBinding:
    prefix: --omit_interval_stat
    position: 15
    shellQuote: false
- id: omit_sample_stat
  label: Omit sample statistics
  doc: |-
    Skip statistics per sample
  type: boolean?
  inputBinding:
    prefix: --omit_sample_stat
    position: 15
    shellQuote: false
- id: include_ref_N
  label: Include N reference
  doc: |-
    Include sites with reference set to N
  type: boolean?
  inputBinding:
    prefix: --include_ref_N
    position: 15
    shellQuote: false
- id: ignore_del_sites
  label: Ignore deletion sites
  doc: |-
    Ignore sites in deletions
  type: boolean?
  inputBinding:
    prefix: --ignore_del_sites
    position: 15
    shellQuote: false
- id: include_del
  label: Include deletions
  doc: |-
    Include deletions. Also add deletion counts. 
    This argument will interact with others as follows:
    * if ignore_del_sites is off, count Deletion as depth
    * if print_base_counts is on, include number of â€˜Dâ€™
  type: boolean?
  inputBinding:
    prefix: --include_del
    position: 15
    shellQuote: false   
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: depth_output
  type: File
  outputBinding:
    glob: '*depth_metrics*'

baseCommand:
- sentieon
- driver
arguments:
- prefix: ''
  position: 10
  valueFrom: --algo CoverageMetrics
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: $(inputs.input_bam.nameroot).depth_metrics
  shellQuote: false
