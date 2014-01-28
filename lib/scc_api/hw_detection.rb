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
      pci_devices = pci_out.split(/^$/)
      vendor_ids = []

      pci_devices.each do |pci_device|
        # 0300 = "VGA compatible controller"
        if pci_device.match /^Class:\s+0300$/
          if pci_device.match /^Vendor:\s+(\d+)/
            vendor_ids << $1
          end
        end
      end

      result = vendor_ids.map { |vendor_id| VENDOR_ID_MAPPING[vendor_id] || UNKNOWN_VENDOR }
      Logger.log.info("HW detection: detected graphics cards vendors: #{result}")

      return result
    end
  end

end
