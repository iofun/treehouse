# spaceboard

The`spaceboard` is a distributed system provided for convenience spawning Linux® daemons and Erlang/OTP processes over time that grow into other units; nodes provide granular unit control with in `spaceboard` clusters, spawn more nodes to allow control of additional units.

Feel free to [explore](https://github.com/spacebeam) and remember; as your system grow in number, you must spawn more nodes to control it.

## Install

You can install `spaceboard` from [hex.pm](https://hex.pm/packages/spaceboard) by including the following in your `rebar.config`:

```
{deps,[
	{spaceboard, "X.Y.Z"}
]}.
```
where _X.Y.Z_ is one of the [release versions](https://github.com/spacebeam/spaceboard/releases).

For more info on rebar3 dependencies see the [rebar3 docs](http://www.rebar3.org/docs/dependencies).

## Help wanted

Would you like to help with the project? Pick any of the issues tagged [help wanted](https://github.com/spacebeam/spaceboard/labels/help%20wanted) and contribute!

## Contributing

See  [Contributing](CONTRIBUTING.md).
