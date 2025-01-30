{
  # Mandatory fields!
  # username = "eisenmann";
  # userFullName = "Petra Eisenmann";
  # email = "petra.eisenmann@active-group.de";
  additionalPackages = pkgs: [
    # pkgs.mercurial
  ];
  additionalModules = settings: [
    # If you choose to opt out of the git configuration, you have to take care
    # to get git via `additionalPackages` or elsewhere
    (import ./git settings)
    # (import ./emacs settings)
  ];
  additionalEmacsPackages = p: [
    # p.ivy
  ];
}
