C++ SQLite Parser
=========================

This is a SQLite Parser for C++. It parses the given SQL statement into C++ objects.

The upstream project [HYRISE sql-parser](https://github.com/hyrise/sql-parser)
is a SQL Parser for C++. This repo is a fork customized for parsing
[SQLite](https://sqlite.org) statements.

While many RDBMS tend to use the standard SQL. Some variations exist, and there
are RDBMS-specific syntax/functionalities. For more details (though not
complete), please see the SQLite wiki:
[Differences Between Engines](http://www.sqlite.org/sqllogictest/wiki?name=Differences+Between+Engines)


## Usage

TBA.

## How to Contribute

We strongly encourage contributors to contribute directly to upstream whenever
possible; contributions will be rejected if we feel they are more appropriate
for a direct upstream contribution (e.g. features for general SQL instead of
SQLite-only queries)

If you would like to contribute to this repository, please submit a pull
request. All submissions, including submissions by project members, require
review. We use GitHub pull requests for this purpose. (For project members,
please use our internal Gerrit.)

We will also submit patches to our upstream project for general SQL stuff.
For changes that are suitable for the upstream project, please create a patch
branch with the newest upstream code on GitHub, and cherry-pick the change
commit to that branch. If inconsistency exists, please amend the change commit
before submitting a pull request to the upstream. After a pull request is
created, please do not amend the commit like Gerrit. Instead, push additional
fix commits.

Because of this, we also ask that project members and contributors try
their best to keep the original structure and naming conventions so that
patches can be easily ported to our upstream.

Thank you in advance!

## License

[MIT](LICENSE)


## Members and Contributers

This fork is maintained by Adam Yi ([@adamyi](https://github.com/adamyi)),
with other project members:

* Fanglin Chen ([@chentc](https://github.com/chentc))
* Charlie Qiu ([@Charlie818](https://github.com/Charlie818))
* Benjamin DROUARD ([@drouarb](https://github.com/drouarb))

We appreciate the help of other open-source contributors! If you are submitting
a pull request, feel free to create a list here and add your name if you want.

The following people contributed to the original HYRISE sql-parser in various
forms:

* Pedro Flemming ([@torpedro](https://github.com/torpedro))
* David Schwalb ([@schwald](https://github.com/schwald))
