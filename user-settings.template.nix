{
  # Edit the following details:

  # This needs to match the name of the actual user on your machine!
  username = "plum";

  # This is the name you'd see (for instance) in git commits
  userFullName = "Plim Plum";

  # This is used primarily for git commits
  email = "plim.plum@active-group.de";

  # Anything in the `nixpkgs` package set that you need, you'd add here
  additionalPackages = pkgs: [
    # Kaan sein Tool would need this:
    # pkgs.jdk
  ];

  # TODO
  additionalModules = settings: [
    # If you choose to opt out of the git configuration, you have to take care
    # to get git via `additionalPackages` or elsewhere
    (import ./git settings)
    # (import ./emacs settings)
    # (import ./controlling)
  ];

  # Additional things/packages your Emacs should come pre-installed with
  additionalEmacsPackages = p: [
    # p.ivy
  ];
}
