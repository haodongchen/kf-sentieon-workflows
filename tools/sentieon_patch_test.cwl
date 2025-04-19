cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_patch_test
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.03
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: image
  type: string
- id: sentieon_license
  type: string
- id: cpu_per_job
  type: int?
- id: mem_per_job
  type: int?

stdout: message

outputs:
  message_string:
    type: string
    outputBinding:
      glob: message
      loadContents: true
      outputEval: $(self[0].contents)

arguments:
- prefix: ''
  position: 1
  valueFrom: ( env LD_DEBUG=libs sentieon driver 2>&1 | grep patch || echo "Not patched" )
  shellQuote: false
