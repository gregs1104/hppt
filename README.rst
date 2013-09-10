hppt
====

High Performance PostgreSQL Tools

Production quality programs for monitoring and tuning a busy PostgreSQL installation.
Tools are broken into rep (replication) and perf (performance) directories.

TODO
====

* There are many hard-coded things in these programs that should be
  more flexible input parameters.  The model for how everything should
  look eventually is the fully command line parameterized
  rep/archive_wal program.  Spots with the hard coded bits are
  usually labelled with "dbXX" as the part that needs to be customized
  right now.

License
=======

Copyright 2013 Gregory Smith gsmith@westnet.com
2-Clause BSD Licensed; see LICENSE for details.
