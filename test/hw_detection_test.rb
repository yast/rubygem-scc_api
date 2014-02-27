#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/hw_detection"

describe SccApi::HwDetection do
  describe ".cpu_sockets" do
    it "returns CPU sockets number" do
      SccApi::HwDetection.should_receive(:'`').with("LC_ALL=C lscpu").and_return(File.read("#{fixtures_dir}/lscpu_1_socket.out"))
      expect(SccApi::HwDetection.cpu_sockets).to eq(1)
    end

    it "raises error when detection fails" do
      SccApi::HwDetection.should_receive(:'`').with("LC_ALL=C lscpu").and_return("")
      expect{SccApi::HwDetection.cpu_sockets}.to raise_error
    end
  end

  describe ".graphics_card_vendors" do
    it "returns graphics cards vendors" do
      SccApi::HwDetection.should_receive(:'`').with('PATH="$PATH":/sbin lspci -n -vmm').and_return(File.read("#{fixtures_dir}/lspci_intel_gfx.out"))
      returned = SccApi::HwDetection.graphics_card_vendors
      expect(returned).to eq(["intel"]), "Detected graphics cards vendors: '#{returned}'"
    end

    it "returns empty array if no graphic card found" do
      SccApi::HwDetection.should_receive(:'`').with('PATH="$PATH":/sbin lspci -n -vmm').and_return(File.read("#{fixtures_dir}/lspci_no_gfx.out"))
      expect(SccApi::HwDetection.graphics_card_vendors).to be_empty
    end

    it "returns #{SccApi::HwDetection::UNKNOWN_VENDOR.inspect} if vendor is not recognized" do
      SccApi::HwDetection.should_receive(:'`').with('PATH="$PATH":/sbin lspci -n -vmm').and_return(File.read("#{fixtures_dir}/lspci_unknown_gfx.out"))
      expect(SccApi::HwDetection.graphics_card_vendors).to include(SccApi::HwDetection::UNKNOWN_VENDOR)
    end
  end

  describe ".collect_hw_data" do
    it "collects all hardware data" do
      SccApi::HwDetection.should_receive(:'`').with('PATH="$PATH":/sbin lspci -n -vmm').and_return(File.read("#{fixtures_dir}/lspci_intel_gfx.out"))
      SccApi::HwDetection.should_receive(:'`').with("LC_ALL=C lscpu").and_return(File.read("#{fixtures_dir}/lscpu_1_socket.out"))
      returned = SccApi::HwDetection.collect_hw_data
      expect(returned).to eq({"sockets" => 1, "graphics" => "intel"})
    end
  end

end
