.. Licensed to the Apache Software Foundation (ASF) under one
.. or more contributor license agreements.  See the NOTICE file
.. distributed with this work for additional information
.. regarding copyright ownership.  The ASF licenses this file
.. to you under the Apache License, Version 2.0 (the
.. "License"); you may not use this file except in compliance
.. with the License.  You may obtain a copy of the License at

..   http://www.apache.org/licenses/LICENSE-2.0

.. Unless required by applicable law or agreed to in writing,
.. software distributed under the License is distributed on an
.. "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
.. KIND, either express or implied.  See the License for the
.. specific language governing permissions and limitations
.. under the License.

.. _ppc64le-support:

PPC64LE Support Status and Action Plan
======================================

This document tracks the current state of PPC64LE support across Apache Arrow,
with a focus on buildability, CI coverage, known gaps, and concrete next
actions.  It is intended to be a single reference for contributors working on
Power architecture enablement across C++, Python, and related components.

Goals
-----

The practical goals for PPC64LE support are:

* keep at least one robust Linux CI lane green on PPC64LE
* maintain clear expectations for supported Ubuntu / toolchain combinations
* document architecture-specific exceptions rather than hiding them in CI only
* identify which Arrow components are currently validated on PPC64LE and which
  are not
* track follow-up work needed to move from "best effort" to "maintained"

Scope
-----

This document covers:

* C++ core and C++ integration tests
* Python / PyArrow build and test implications
* filesystem and network-backed integrations such as S3
* supporting CI and Docker infrastructure
* adjacent components which may need validation later, such as Gandiva,
  Flight, Dataset, Parquet, and packaging workflows

It does not by itself declare an official project-wide support guarantee.
Rather, it records the current operational status and the work needed to make
that support reliable.

Current CI Position
-------------------

At the time of writing, PPC64LE CI work has focused primarily on C++ Linux
builds running on self-hosted GitHub Actions runners.

Current intended lanes:

* Ubuntu 22.04 PPC64LE C++ CPU-only
* Ubuntu 24.04 PPC64LE C++ CPU-only

The Ubuntu 22.04 PPC64LE lane required targeted fixes to align the workflow,
Docker image, toolchain selection, and runtime test expectations with the
realities of the platform.

C++ Status
----------

Current status
++++++++++++++

C++ is the most advanced Arrow component for PPC64LE enablement today.  The
main build and test path exists, and recent work has addressed several concrete
PPC64LE-specific failures in CI.

Resolved issues
+++++++++++++++

1. Incorrect GitHub Actions service selection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Ubuntu 22.04 PPC64LE workflow entry pointed to the ``ppc64le-cpp`` compose
service, which in turn referenced a Dockerfile path that did not exist.  The
correct service for Ubuntu-based PPC64LE builds is ``ubuntu-ppc64le-cpp``.

Fix applied:

* the Ubuntu 22.04 PPC64LE workflow now uses ``image: ubuntu-ppc64le-cpp``

2. LLVM 18 availability on Ubuntu 22.04 PPC64LE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Ubuntu 22.04 PPC64LE Docker image attempted to install LLVM 18 and related
clang tooling.  Those packages are not reliably available for PPC64LE on the
expected package sources, causing Docker build failures.

Fix applied:

* Ubuntu 22.04 PPC64LE now uses:
  * ``clang-tools: 14``
  * ``llvm: 14``

This matches the safe baseline for the distribution and avoids depending on an
unreliable external LLVM 18 path.

3. CMake installation on PPC64LE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The shared CMake installer script did not support ``ppc64le`` and exited
successfully without installing anything.  This caused the container to build
but later fail with ``cmake: command not found``.

A second fallback to distro CMake on Ubuntu 22.04 was insufficient because the
available version was ``3.22.1``, while Arrow now requires CMake 3.25 or newer.

Fix applied:

* the Ubuntu 22.04 PPC64LE Dockerfile now installs
  ``cmake==3.28.3`` via ``python3 -m pip``

This gives a sufficiently new CMake version on PPC64LE without depending on the
unsupported Kitware binary installer path.

4. Jemalloc retained-memory test instability
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A jemalloc statistics assertion in ``cpp/src/arrow/memory_pool_test.cc`` was
too strict on PPC64LE.  The test assumed that ``stats.retained`` remained near
stable over a small allocate / reallocate / free sequence, but on PPC64LE the
allocator legitimately released or repurposed retained extents between
snapshots.

Fix applied:

* the PPC64LE branch of the test now performs validity-only checks for
  ``stats.retained`` instead of asserting a near-zero delta

This preserves test intent while removing a platform-specific false failure.

5. Slow S3 integration test lane
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``arrow-s3fs-test`` was not obviously functionally broken on PPC64LE, but it
was slower on the Ubuntu 22.04 Power runner and needed additional time.

Fix applied:

* the Ubuntu 22.04 PPC64LE lane now uses a larger per-test timeout via
  ``ARROW_CTEST_TIMEOUT=900``

Remaining C++ risks
+++++++++++++++++++

Even after the fixes above, PPC64LE C++ support should still be considered
active work rather than fully mature.  Remaining areas to watch:

* filesystem-backed integration tests are slower and may require further tuning
* memory allocator metrics may differ from x86_64 assumptions in subtle ways
* package availability on Ubuntu 22.04 is materially different from 24.04
* large tests involving S3, dataset scanning, or Parquet may be more sensitive
  to host performance variance on Power hardware

C++ action items
++++++++++++++++

High priority:

* verify clean CI runs for both Ubuntu 22.04 and Ubuntu 24.04 PPC64LE lanes
* confirm that the increased timeout resolves the S3FS job consistently
* add explanatory comments in workflow and Dockerfile files for the PPC64LE
  LLVM and CMake choices

Medium priority:

* extend ``ci/scripts/install_cmake.sh`` to explicitly support ``ppc64le``, or
  document why pip-installed CMake is the preferred path on that architecture
* review other architecture-sensitive tests for assumptions on page size,
  alignment, allocator stats, and test duration
* consider splitting especially heavy integration tests into their own PPC64LE
  lane if runtime becomes unstable

Python / PyArrow Status
-----------------------

Current status
++++++++++++++

Python support on PPC64LE should be treated as **partially understood, not yet
fully validated** in the same way as the current C++ lane.

The main considerations for Python on PPC64LE are different from C++:

* wheel availability and packaging are critical
* build-time dependencies may behave differently from x86_64
* Python test coverage depends on a valid underlying C++ stack
* Arrow optional components such as Parquet, Dataset, Flight, S3, and ORC all
  influence Python build success and runtime behavior

What is likely already true
+++++++++++++++++++++++++++

If C++ builds and installs cleanly on PPC64LE, then source-based PyArrow builds
are more plausible, especially in development environments.  However, that does
not imply that:

* release-quality wheels exist for PPC64LE
* manylinux / musllinux wheel jobs are configured for PPC64LE
* all Python tests pass on PPC64LE
* dependencies used by PyArrow are available in matching versions on PPC64LE

Known Python questions
++++++++++++++++++++++

The following questions still need explicit validation:

* Can ``python setup.py build_ext`` or the modern equivalent complete cleanly on
  PPC64LE with the current C++ fixes?
* Are Arrow Python optional dependencies available and version-compatible on
  PPC64LE?
* Which Python test groups pass, and which are too slow or architecture
  sensitive?
* Are there PPC64LE-compatible binary distribution stories for:
  * pip wheels
  * conda packages
  * source distributions with local builds
* Are there any endian- or alignment-sensitive Python test failures surfacing
  through NumPy, pandas, or pyarrow compute bindings?

Python action items
+++++++++++++++++++

High priority:

* add or validate at least one PPC64LE source-build PyArrow CI lane
* verify import, build, and a representative test subset:
  * core array/table functionality
  * Parquet
  * Dataset
  * filesystem integrations where supported
* document whether PPC64LE Python support is source-build only or also expected
  to have binary artifacts

Medium priority:

* audit wheel-building infrastructure for PPC64LE feasibility
* identify whether manylinux-based wheel tooling can practically support
  PPC64LE in the current release process
* evaluate test exclusions or timeout multipliers needed for slower runners

Suggested minimum Python validation target:

* build PyArrow from source on PPC64LE
* run smoke tests for import, arrays, tables, compute, parquet, dataset
* separately classify optional integrations such as S3, Flight, and ORC

Parquet, Dataset, Flight, Gandiva, and Filesystems
--------------------------------------------------

These components are mainly exercised through the C++ configuration today, but
deserve explicit tracking because they often amplify architecture issues.

Parquet
+++++++

Status:

* built and tested through the C++ PPC64LE lane
* likely viable if the C++ lane stays green

Action items:

* confirm no PPC64LE-specific encoding / decoding regressions remain
* monitor slower test execution on Power hardware
* validate Python Parquet bindings once PyArrow PPC64LE testing exists

Dataset
+++++++

Status:

* enabled in PPC64LE C++ lanes
* dependent on C++ core, filesystem, and Parquet health

Action items:

* monitor scan-heavy tests for runtime stability
* validate PyArrow dataset bindings on PPC64LE once Python CI exists

Flight / Flight SQL
+++++++++++++++++++

Status:

* enabled in PPC64LE C++ lanes
* not yet separately documented as PPC64LE-supported beyond build/test presence

Action items:

* validate whether all Flight integration tests are stable on PPC64LE
* identify any gRPC or dependency version constraints specific to Power
* explicitly test Python Flight bindings on PPC64LE if Python support is added

Gandiva
+++++++

Status:

* enabled in current PPC64LE C++ Docker configurations
* potentially more sensitive than many other subsystems because of LLVM
  dependency complexity

Action items:

* monitor Gandiva specifically when changing LLVM versions on PPC64LE
* document whether Ubuntu 22.04 + LLVM 14 remains sufficient for Gandiva
* consider whether Gandiva needs a narrower support statement than core Arrow
  C++

Filesystems and cloud integrations
++++++++++++++++++++++++++++++++++

Status:

* filesystem and object store tests are among the slowest PPC64LE jobs
* S3 has already needed timeout adjustments

Action items:

* continue monitoring S3FS runtime and flakiness on PPC64LE
* classify whether slow failures are functional or infrastructure-related
* evaluate GCS and Azure support separately if those integrations are to be
  considered part of PPC64LE support expectations

Packaging and Distribution
--------------------------

Current status
++++++++++++++

Packaging for PPC64LE is less mature than source builds.  In practice, PPC64LE
support often succeeds first via source builds in controlled environments and
only later through polished binary distribution pipelines.

Areas needing explicit decisions
++++++++++++++++++++++++++++++++

* Is PPC64LE support expected to be source-only, binary-distributed, or both?
* Should PPC64LE be included in release validation workflows?
* Are conda packages available and tested?
* Are Python wheels in scope for PPC64LE?
* Which Docker images should be considered supported developer environments?

Packaging action items
++++++++++++++++++++++

* inventory current release artifacts for PPC64LE by language / package manager
* document whether PPC64LE is officially supported, experimentally supported, or
  best-effort for:
  * C++
  * Python
  * R
  * Java
  * GLib
* determine whether Crossbow / release automation should gain PPC64LE tasks
* define a minimal release verification checklist for PPC64LE if binary support
  is desired

Other Language Bindings and Components
--------------------------------------

R
+

Questions to answer:

* does R build against PPC64LE with the current C++ baseline?
* are the Arrow R tests expected to pass on PPC64LE?
* are required system dependencies available on PPC64LE distributions?

Action items:

* attempt a source build of the R package on PPC64LE
* run a smoke subset of R tests
* document whether R PPC64LE support is best-effort or actively maintained

Java
++++

Questions to answer:

* are Java CI builds or package builds currently validated on PPC64LE?
* is JNI or Gandiva-related Java functionality impacted by Power-specific LLVM
  or native toolchain differences?

Action items:

* inventory whether Java release artifacts or test jobs exist for PPC64LE
* define whether Java is in or out of current PPC64LE scope

GLib, Ruby, MATLAB, and others
++++++++++++++++++++++++++++++

These should be treated as unknown until validated.

Action items:

* list which of these have any current PPC64LE CI coverage
* separate "not tested" from "known unsupported"
* avoid implying support where only source compatibility is assumed

Cross-cutting CI and Infrastructure Action Items
------------------------------------------------

High priority
+++++++++++++

* keep both Ubuntu 22.04 and 24.04 PPC64LE C++ lanes running
* ensure self-hosted runner capacity is stable and well understood
* document architecture-specific timeout overrides and toolchain pins
* capture PPC64LE-specific exceptions in documentation, not only in workflow
  files

Medium priority
+++++++++++++++

* add a dedicated PPC64LE section to CI documentation navigation
* consider a standard matrix field for architecture-specific timeout overrides
* review whether some long-running integration tests should be serialized or
  isolated on PPC64LE

Lower priority but useful
+++++++++++++++++++++++++

* add local developer instructions for reproducing PPC64LE CI failures
* add notes on package availability differences between Ubuntu 22.04 and 24.04
* define a policy for when architecture-specific test relaxations are acceptable

Suggested Support Levels
------------------------

Until broader validation exists, the following language is reasonable:

C++
+++

* **Actively maintained on PPC64LE via Linux CI**
* current target environments:
  * Ubuntu 22.04
  * Ubuntu 24.04

Python
++++++

* **Expected to be source-buildable once C++ is healthy, but not yet fully
  validated as a maintained PPC64LE target**

Other components
++++++++++++++++

* **Unknown or best-effort until explicit CI or release validation exists**

Definition of Done for "Maintained PPC64LE Support"
---------------------------------------------------

A practical bar for maintained PPC64LE support would be:

1. At least one stable, non-flaky CI lane for C++
2. Documented toolchain and OS support matrix
3. Source-build validation for Python
4. Clear statement on binary packaging expectations
5. Explicit classification of other bindings:
   * maintained
   * best-effort
   * not currently validated
6. Architecture-specific test exceptions documented and justified

Immediate Next Steps
--------------------

1. Re-run both PPC64LE C++ lanes and confirm clean results
2. Add this document to the developer CI toctree
3. Add short comments in workflow / Docker files for PPC64LE-specific choices
4. Create at least one PPC64LE Python validation path
5. Inventory support status for R, Java, GLib, and packaging pipelines
6. Convert open PPC64LE issues into a tracked checklist or project board

Summary
-------

PPC64LE support is now materially better for Arrow C++ on Ubuntu 22.04 and
24.04, with several concrete CI blockers already resolved.  However, project
wide PPC64LE support is not just a C++ question.  Python, packaging, release
validation, and other bindings still need explicit validation and documentation.

The current state is best described as:

* C++ PPC64LE support: actively being stabilized
* Python PPC64LE support: plausible but not yet fully validated
* other components: unclassified until tested

The next milestone is to move from "C++ lane repaired" to "documented,
repeatable, cross-component PPC64LE support posture".

.. Made with Bob
