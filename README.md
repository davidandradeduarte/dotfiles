# Dotfiles

A dotfiles manager for personal use.

No automation tools being used, just plain shell scripts and symbolic links.

Currently supports: macOS, Ubuntu, Fedora.

Use at your own risk.

Table of Contents
-----------------

* [Installation](#installation)
* [Docker](#docker)
* [Testing](#testing)
* [License](#license)

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/davidandradeduarte/dotdot/HEAD/install | bash
```

Alternatively, you can clone the repository and run the `install` script:

```sh
git clone https://github.com/davidandradeduarte/dotdot.git
cd dotdot
./install
```

**Options**

| Flag | Description | Default |
| - | - | - |
| -d, --dir | Dotfiles directory | `$HOME/.dotfiles` |
| -s, --shell | Default shell | `$SHELL` |
| -y, --yes | No prompt |
| -l, --local | Local mode |
| -h, --help | Show help |

All flags are available as environment variables in their --`name` form.

**Examples**

Using flags:

```sh
curl -fsSL https://raw.githubusercontent.com/davidandradeduarte/dot/HEAD/install.sh | bash -s -- -d "$HOME/.dot" -s zsh -y
```

Using environment variables:

```sh
dir="$HOME/.dot" shell=zsh yes=true curl -fsSL https://raw.githubusercontent.com/davidandradeduarte/dot/HEAD/install.sh | bash
```

*(booleans can be `true` or `1`)*

## Docker

```sh
docker run -it --rm davidduarte/dotfiles:ubuntu
```

All options are available as environment variables too:

```sh
docker run -it --rm -e dir="$HOME/.dot" -e shell=zsh -e yes=true davidduarte/dotfiles:ubuntu
```

See the available tags [here](https://hub.docker.com/r/davidduarte/dotfiles/tags).

Available images:

## Testing

The `local` option allows you to test dotfiles changes by copying the current directory instead of cloning the remote repository.

Use the make targets to test the installation on different OSs or to install the dotfiles locally.

All options are available as make variables and there's an extra `quiet` flag to silence docker output.

**Examples**

Spin up a container with Ubuntu to test local changes:

```sh
make ubuntu local=true
```

*(if `local=true` is not set, it will clone the remote repository instead of copying your local changes)*

Using all options:

```sh
make ubuntu dir="$HOME/.dot" shell=zsh yes=true local=true quiet=true
```

See the available targets in the [Makefile](Makefile).

## License

[MIT](LICENSE)
