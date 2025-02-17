{
  # Mandatory fields!
  # username = "eisenmann";
  # userFullName = "Petra Eisenmann";
  # email = "petra.eisenmann@active-group.de";
  additionalPackages = pkgs: [
    # Kaan sein Tool would need this:
    # pkgs.jdk
  ];
  additionalModules = settings: [
    # If you choose to opt out of the git configuration, you have to take care
    # to get git via `additionalPackages` or elsewhere
    (import ./git settings)
    # (import ./emacs settings)
    # (import ./controlling)
  ];
  additionalEmacsPackages = p: [
    # p.ivy
  ];
}
