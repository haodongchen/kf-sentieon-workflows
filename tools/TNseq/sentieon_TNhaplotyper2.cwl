cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_TNhaplotyper2
doc: |-
  Run Sentieon TNseq tool.
  
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
- id: min_base_qual
  label: Minimum base quality
  doc: |-
    Minimum base quality to consider default 10
  type: int?
  inputBinding:
    prefix: --min_base_qual
    position: 15
  sbg:toolDefaultValue: '10'
- id: pcr_indel_model
  label: PCR indel error model
  doc: |-
    PCR indel error model: none, hostile, aggressive, or conservative
  type:
  - 'null'
  - name: pcr_indel_model
    type: enum
    symbols:
    - none
    - hostile
    - aggressive
    - conservative
  inputBinding:
    prefix: --pcr_indel_model
    position: 15
  sbg:toolDefaultValue: 'conservative'
- id: prune_factor
  label: Pruning factor
  doc: |-
    Pruning factor in the kmer graph. 0 means adaptive pruning.
  type: int?
  inputBinding:
    prefix: --prune_factor
    position: 15
  sbg:toolDefaultValue: '0'
- id: germline_vcf
  label: Germline VCF
  doc: |-
    Germline VCF file contains allele frequency
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: true
  inputBinding:
    prefix: --germline_vcf
    position: 15
- id: default_af
  label: Default AF in not in germline VCF
  doc: |-
    Default allele frequency if allele is not found in germline vcf
    Default value 1e-6 for tumor-normal, 5e-8 for tumor-only
  type: float?
  inputBinding:
    prefix: --default_af
    position: 15
- id: max_germline_af
  doc: Maximum germline allele frequency in tumor-only mode
  type: float?
  inputBinding:
    prefix: --max_germline_af
    position: 15
  sbg:toolDefaultValue: '0.01'
- id: pon
  label: PON
  doc: Panel-of-normal file
  type: File?
  inputBinding:
    prefix: --pon
    position: 15
- id: call_pon_sites
  label: Call sites in PON
  doc: Call candidates even in the PoN
  type: boolean?
  inputBinding:
    prefix: --call_pon_sites
    position: 15  
  sbg:toolDefaultValue: 'false'
- id: min_init_tumor_lod
  label: Minimum initial TLOD
  doc: Minimum tumorLOD for candidate selection
  type: float?
  inputBinding:
    prefix: --min_init_tumor_lod
    position: 15
  sbg:toolDefaultValue: '2.0'
- id: min_tumor_lod
  label: Minimum TLOD
  doc: Minimum tumorLOD to emit
  type: float?
  inputBinding:
    prefix: --min_tumor_lod
    position: 15
  sbg:toolDefaultValue: '3.0'
- id: min_normal_lod
  label: Minimum NLOD
  doc: Minimum normalLOD
  type: float?
  inputBinding:
    prefix: --min_normal_lod
    position: 15
  sbg:toolDefaultValue: '2.2'
- id: trim_soft_clip
  label: Trim soft clip
  doc: Trim off soft-clipped bases
  type: boolean?
  inputBinding:
    prefix: --trim_soft_clip
    position: 15  
  sbg:toolDefaultValue: 'false'
- id: callable_depth
  label: Callable depth
  doc: Minimum depth to be considered callable for output statistics
  type: int?
  inputBinding:
    prefix: --callable_depth 
    position: 15
  sbg:toolDefaultValue: '10'
- id: given
  label: Given VCF file
  doc: |-
    Call the variants given in a vcf file, in addition to others
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: --given 
    position: 15
- id: call_germline_sites
  doc: Call candidates even at germline sites
  type: boolean?
  inputBinding:
    prefix: --call_germline_sites
    position: 15  
  sbg:toolDefaultValue: 'false'
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".vcf.gz".
  type: string
  inputBinding:
    position: 100
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: output_vcf
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: '*.vcf.gz'
  sbg:fileTypes: VCF.GZ
- id: stats_file
  type: File
  outputBinding:
    glob: '*.stats'
baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: TNhaplotyper2
  shellQuote: false
