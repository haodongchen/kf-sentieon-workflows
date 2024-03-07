cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_TNfilter
doc: |-
  Run Sentieon TNfilter tool.
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input VCF``: Location of the VCF from TNhaplotyper2.
  - ``tumor_sample``: Tumor sample name

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
- id: input_vcf
  label: Input VCF
  doc: Input VCF file
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: -v
    position: 11
  sbg:fileTypes: VCF, VCF.GZ  
- id: tumor_sample
  label: Tumor sample name
  type: string
  inputBinding:
    prefix: --tumor_sample
    position: 12
- id: normal_sample
  label: Normal sample name. 
  doc: Normal sample name. If not set, normal artifact filter is disabled for tumor-only mode
  type: string?
  inputBinding:
    prefix: --normal_sample
    position: 13

- id: threshold_strategy
  label: Threshold Strategy
  doc: |-
    Method to determine filtering threshold.
    Options include f_score, precision, constant
  type:
  - 'null'
  - name: threshold_strategy
    type: enum
    symbols:
    - f_score
    - precision
    - constant
  inputBinding:
    prefix: --threshold_strategy
    position: 15
  sbg:toolDefaultValue: 'f_score'
- id: f_score_beta
  doc: |-
    Relative weight of recall to precision.
    For f_score strategy only
  type: float?
  inputBinding:
    prefix: --f_score_beta
    position: 16
  sbg:toolDefaultValue: '1'
- id: max_fp_rate
  doc: |-
    Maximum expected false positive rate.
    For precision strategy only
  type: float?
  inputBinding:
    prefix: --max_fp_rate
    position: 16
  sbg:toolDefaultValue: '0.05'
- id: threshold
  doc: |-
    Threshold for constant strategy only
  type: float?
  inputBinding:
    prefix: --threshold
    position: 16
  sbg:toolDefaultValue: '0.1'
- id: min_median_base_qual
  label: base_qual
  doc: Minimum median base quality
  type: int?
  inputBinding:
    prefix: --min_median_base_qual
    position: 20
  sbg:toolDefaultValue: '20'
- id: max_event_count
  label: clustered_events
  doc: Maximum number of events in active region
  type: int?
  inputBinding:
    prefix: --max_event_count
    position: 20
  sbg:toolDefaultValue: '2'
- id: contamination
  label: contamination
  doc: Path to the contamination table from ContaminationModel
  type: File?
  inputBinding:
    prefix: --contamination
    position: 20
- id: unique_alt_reads
  label: duplicate
  doc: Minimum number of unique alt reads
  type: int?
  inputBinding:
    prefix: --unique_alt_reads
    position: 20
  sbg:toolDefaultValue: '0'
- id: max_mfrl_diff
  label: fragment
  doc: Maximum median fragment length difference
  type: int?
  inputBinding:
    prefix: --max_mfrl_diff
    position: 20
  sbg:toolDefaultValue: '10000'
- id: tumor_segments
  label: germline
  doc: Tumor segmentation table from ContaminationModel
  type: File?
  inputBinding:
    prefix: --tumor_segments
    position: 20
- id: max_haplotype_distance
  label: haplotype
  doc: Maximum distance within a haplotype to determine artifact probablity
  type: int?
  inputBinding:
    prefix: --max_haplotype_distance
    position: 20
  sbg:toolDefaultValue: '100'
- id: min_tumor_af
  label: low_allele_frac
  doc: Minimum tumor allele fraction
  type: float?
  inputBinding:
    prefix: --min_tumor_af
    position: 20
  sbg:toolDefaultValue: '0'
- id: min_median_map_qual
  label: map_qual
  doc: Minimum median mapping quality
  type: int?
  inputBinding:
    prefix: --min_median_map_qual
    position: 20
  sbg:toolDefaultValue: '30'
- id: long_indel_length
  label: map_qual
  doc: Indels longer than this value will use reference mapping quality
  type: int?
  inputBinding:
    prefix: --long_indel_length
    position: 20
  sbg:toolDefaultValue: '5'
- id: max_alt_count
  label: multiallelic
  doc: Maximum number of ALT alleles at a given site
  type: int?
  inputBinding:
    prefix: --max_alt_count
    position: 20
  sbg:toolDefaultValue: '1'
- id: max_n_ratio
  label: n_ratio
  doc: Maximum ratio of N-bases to Alt
  type: float?
  inputBinding:
    prefix: --max_n_ratio
    position: 20
  sbg:toolDefaultValue: '1'
- id: normal_p_value
  label: normal_artifact
  doc: P-value threshold for normal artifact
  type: float?
  inputBinding:
    prefix: --normal_p_value
    position: 20
  sbg:toolDefaultValue: '0.001'
- id: orientation_priors
  label: orientation
  doc: Orientation bias prior table from OrientationBias
  type: File?
  inputBinding:
    prefix: --orientation_priors
    position: 20
- id: min_median_pos
  label: position
  doc: Minimum median distance to the end of the read
  type: int?
  inputBinding:
    prefix: --min_median_pos
    position: 20
  sbg:toolDefaultValue: '1'
- id: min_slippage_length
  label: slippage
  doc: Minimum length in STR likely to have polymerase slippage
  type: int?
  inputBinding:
    prefix: --min_slippage_length
    position: 20
  sbg:toolDefaultValue: '8'
- id: slippage_rate
  label: slippage
  doc: Slippage rate in likely area
  type: float?
  inputBinding:
    prefix: --slippage_rate
    position: 20
  sbg:toolDefaultValue: '0.1'
- id: min_alt_reads_per_strand
  label: strict_strand
  doc: Minimum number of ALT reads on each strand
  type: int?
  inputBinding:
    prefix: --min_alt_reads_per_strand
    position: 20
  sbg:toolDefaultValue: '0'
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
  valueFrom: TNfilter
  shellQuote: false
