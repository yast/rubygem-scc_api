Documentation for Developers
============================

Automatic Package Build
-----------------------

The package is handled by internal Jenkins CI node, it handles building the
package and submitting it into Build Service.


- Every commit to `master` branch is built by [the Jenkins CI
  node](http://river.suse.de/view/YaST/job/rubygem-scc_api-master/)
- When the build succeeds (the tests pass) the package is submitted to
  [Devel:YaST:Head](https://build.suse.de/package/show/Devel:YaST:Head/rubygem-scc_api)
  IBS project.
- If the `VERSION` is changed a submit request is automatically sent to
  [SUSE:SLE-12:GA](https://build.suse.de/project/show/SUSE:SLE-12:GA) IBS
  project.
- The built RPM package is also used for building our testing ISO image in
  [Devel:YaST:Head](https://build.suse.de/package/show/Devel:YaST:Head/minidvd-x86_64),
  the ISO for testing can be downloaded
  [here](http://download.suse.de/ibs/Devel:/YaST:/Head/images/iso/)
  <br>*Note:* the ISO is *not* signed by the official SUSE GPG key, you need to boot with
  `insecure=1` boot option otherwise the installation fails with an error.


Development Notes
-----------------

- Do not use external rubygems or external command line tools unless really
  needed. The package is used at installation when the system runs from RAM
  disk and the space is critical. (Using tools/gems which are already present
  is OK.)
- Keep the API clean and *generic* so it not specific just for your use case.
- Write as much tests as possible, `scc_api` uses [RSpec](https://relishapp.com/rspec/)
  testing framework
- [Travis](https://travis-ci.org/yast/rubygem-scc_api) integration is enabled, it will
  automatically check whether the tests pass. So you should run the tests *before*
  creating a pull request to avoid problems later.
- [CodeClimate](https://codeclimate.com/github/yast/rubygem-scc_api)
  integration is enabled, make sure your commits do not decrease the code
  quality too much :wink:
