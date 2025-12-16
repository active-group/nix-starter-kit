# Contact management using khard

Configure the module to point to a directory containing vcf files.
The [vcf dir inside the active group addresses
repo](https://gitlab.active-group.de/ag/addresses/-/tree/main/vcf) can be used
for example.

```nix
active-group = {
    khard = {
      enable = true;
      # Example storagePath: /home/<mitarbeity>/ag/addresses/vcf
      storagePath = "/<absolute>/<path>/<to>/<dir>/<with>/<vcf-files>";
    };
  };
```
