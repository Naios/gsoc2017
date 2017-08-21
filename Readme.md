# GSoC 2017 [@STEllAR-GROUP/hpx](https://github.com/STEllAR-GROUP/hpx)

**Project:** [Re-implementing hpx::util::unwrapped and unifying the API of hpx::wait and hpx::when](https://summerofcode.withgoogle.com/projects/#5515024297623552)

**Student:** Denis Blank

**Supervisor:** Hartmut Kaiser

-----

## Overview

The following report will describe my progress of my GSoC 2017 project:
"Re-implementing hpx::util::unwrapped and unifying the API of hpx::wait and hpx::when"
that was supervised by Hartmut Kaiser.

The main task of this project was to provide two utility APIs for traversing and mapping
objects in arbitrary variadic packs. There will be a synchronous and an asynchronous version of the traversal API, while mapping will only be supported synchronously.

Both utility APIs will be used to remove code duplication as well as making the
APIs which unwrap or wait for futures more uniform.
Additionally, the APIs introduce support for move only types as well as better support
for objects which are deeply nested inside homogeneous containers (`std::vector`, `std::list`)
and tuple like containers (`std::tuple`, `hpx::util::tuple`, `std::array`).

Below you can see, for which APIs the traversal and mapping APIs could
replace the internal implementation:

     synchronous     *--> unwrap, unwrapping, unwrapped
     mapping and ----*--> wait_all, wait_any, wait_some
    traversal API    *--> when_any, when_some
    
     asynchronous    *--> when_all
     traversal API --*
                     *--> dataflow

Through this contribution, many issues in the HPX issue tracker could be approached or closed,
for instance: #1126 [1], #1132 [2], #1400 [3], #1404 [4] and #2456 [5].

A detailed description of my project may be found here [6].

The following sections will describe the progress which I made in the particular
phases of my Google Summer of Code project in detail.

## Contributions

TODO List of commits



## Progress
### Community Bonding Phase:

During the community bonding phase, I approached some light defects in order
to get used to the codebase as well as getting to know the HPX community.
Meanwhile, I contributed to three particular fields of the HPX project:

- **Documentation improvements:**
    - invoke
    - invoke_fused
    - unwrapped
- **CMake improvements:**
    - A working directory pollution was fixed
    - Soft link creation on Windows was enabled
- **Doxygen improvements:**
    - Autolinking was fixed in some cases
    - The `detail` namespace is excluded in the documentation by default now

If you are interested in the mentioned commits in detail,
you may take a look at my GitHub HPX commit history [7].

### Phase one (June):

At the beginning of the first phase, I focused on fixing the requirements
of my project. Due to this I discovered the need of a `spread` or `explode`
helper function which could invoke a callable object with the content of a given
tuple directly, while passing non tuple like types through.
A detailed description of my research can be found here [8].

In the remaining time of the first phase, I implemented the synchronous mapping
and traversal API `map_pack` and `traverse_pack`, which was submitted as part of
pull request #2704.

A minimalistic example of a typical use case of this API might be the following,
where we map all values to floats:

```cpp
hpx::util::tuple<float, std::vector<float>,
                 hpx::util::tuple<float, float>> res =
map_pack([](int i) {
    return float(i);
}, 1, std::vector<int>{2, 3, 4}, hpx::util::make_tuple(5, 6));
```

The API fully supports all requirements mentioned above like arbitrarily nested containers
and move only types. Thus it's a real improvement over the previous internal code
of the `unwrapped` function.

Since the API isn't fixed on mapping hpx::lcos::future objects we can test it,
with more generic unit tests. Also, we are able to test the mapping API and the
future unwrap functionality independently from each other.

Additionally, the capability to test for compiler features directly with header only
parts of HPX was added to CMake.
This is used to provide a generic feature test, that uses the `traverse_pack` API,
which tests whether the currently used compiler is capable of
full expression SFINAE support.

### Phase two (July):

Based on the mapping API which was implemented in phase one,
`unwrapped` was reimplemented. The PR #2741 which covers this implementation
is closed to be finished and may be viewed at [10].

Due to the requirement, that the new unwrapped should pass none future
arguments through, it was considered to split the deferred and the immediate
unwrapped into two separated interfaces,
since the implementation selection of `unwrapped` would be broken otherwise:

- `unwrap`: Unwraps a variadic pack of futures directly
- `unwrapping`: Creates a callable object that unwraps the futures

Also, multiple versions of `unwrap` and `unwrapping` are provided to unwrap
until a particular future depth of a given pack:

- `unwrap_n` and `unwrapping_n`: Unwraps futures recursively until depth `n`.
- `unwrap_all` and `unwrapping_all`: Unwraps all futures recursively which occur inside the pack.

Currently, the old `unwrapped` function forwards its input to `unwrap` and `unwrapping`,
so we are able to test the behavior of the new implementation.
The next step would be to replace all occurrences of `unwrapped` through
`unwrap` and `unwrapping` accordingly while officially deprecating the `unwrapped` API.

Overall this step took me longer than expected, mainly because the exact behavior
of `unwrapped` was unknown and thus it had to be derived from many unit tests and examples.

Due to the previously named reasons and because a future<T...> is currently considered,
the mapping API was improved recently, to also support 1:n mappings.

## Phase three prospects (August):

For the third phase of my GSoC project, I plan to implement the asynchronous traversal API,
which makes it possible to traverse futures inside a variadic pack while being able
to suspend the current execution context. This would be equal to a stackless coroutine.

Finally, I intend to replace the internal API of `wait_*` and `when_*` with either
the synchronous or asynchronous traversal API so all of those interfaces are able to
deal with the same set or arguments (unification).


If you have any questions regarding my GSoC project,
don't hesitate to reply to this post.
I'm looking forward to receiving your feedback.

Best regards,
Denis

- [1]  https://github.com/STEllAR-GROUP/hpx/issues/1126
- [2]  https://github.com/STEllAR-GROUP/hpx/issues/1132
- [3]  https://github.com/STEllAR-GROUP/hpx/issues/1400
- [4]  https://github.com/STEllAR-GROUP/hpx/issues/1404
- [5]  https://github.com/STEllAR-GROUP/hpx/issues/2456
- [6]  https://cdn.rawgit.com/Naios/hpx/proposal/blank_proposal_light.pdf
- [7]  https://github.com/STEllAR-GROUP/hpx/commits/master?author=Naios
- [8]  https://cdn.rawgit.com/Naios/hpx/proposal/research.pdf
- [9]  https://github.com/STEllAR-GROUP/hpx/pull/2704
- [10] https://github.com/STEllAR-GROUP/hpx/pull/2741
