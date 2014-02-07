# encoding: utf-8

require "scc_api/logger"

module SccApi

  # TODO FIXME: add Yardoc comments
  class HwDetection
    include Logger

    # the most important are ATI and nVidia for which we can offer driver
    # repositories, the rest is not important
    VENDOR_ID_MAPPING = {
      "1002" => "ati",
      "10de" => "nvidia",
      "8086" => "intel"
    }

    UNKNOWN_VENDOR = "unknown"

    def self.cpu_sockets
      ret = `LC_ALL=C lscpu`

      if ret.match /^Socket\(s\):\s*(\d+)\s*$/
        log.info("HW detection: detected #{$1} CPU sockets")
        return $1.to_i
      else
        raise "CPU detection failed"
      end
    end

    def self.graphics_card_vendors
      # only PCI cards are supported (for others we cannot provide driver repos anyway)
      # -n = numeric IDs
      # -vmm = machine readable format
      # add "/sbin" to the end of $PATH to be sure that "lspci" is found
      # when not running as root
      pci_out = `PATH="$PATH":/sbin lspci -n -vmm`

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

      log.info("HW detection: detected graphics cards vendors: #{result}")

      return result
    end

    def self.collect_hw_data
      # TODO FIXME: check the expected structure
      {
        "sockets" => HwDetection.cpu_sockets,
        # TODO FIXME: the API supports only a single vendor, change it to list?
        "graphics" => HwDetection.graphics_card_vendors.first
      }
    end
  end

end
