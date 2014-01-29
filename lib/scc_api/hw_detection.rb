# encoding: utf-8

require "scc_api/logger"

module SccApi

  # TODO FIXME: add Yardoc comments
  class HwDetection

    # the most important are ATI and nVidia for which we can offer driver
    # repositories, the rest is not important
    VENDOR_ID_MAPPING = {
      "1002" => "ati",
      "10de" => "nvidia",
      "8086" => "intel"
    }

    UNKNOWN_VENDOR = "unknown"

    def self.cpu_sockets
      lc_all_bak = ENV["LC_ALL"]
      # run "lscpu" in "C" locale to suppress translations
      ENV["LC_ALL"] = "C"
      ret = `lscpu`

      if ret.match /^Socket\(s\):\s*(\d+)\s*$/
        Logger.log.info("HW detection: detected #{$1} CPU sockets")
        return $1.to_i
      else
        raise "CPU detection failed"
      end
    ensure
      ENV["LC_ALL"] = lc_all_bak
    end

    def self.graphics_card_vendors
      # only PCI cards are supported (for others we cannot provide driver repos anyway)
      # -n = numeric IDs
      # -vmm = machine readable format
      pci_out = `lspci -n -vmm`

      # the devices are separated by empty line
      result = pci_out.split(/^$/).reduce([]) do |result, pci_device|
        # 0300 = "VGA compatible controller"
        if pci_device.match /^Class:\s+0300$/
          if pci_device.match /^Vendor:\s+(\d+)/
            result << VENDOR_ID_MAPPING[$1] || UNKNOWN_VENDOR
          end
        end
        result
      end

      Logger.log.info("HW detection: detected graphics cards vendors: #{result}")

      return result
    end
  end

end
