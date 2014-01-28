#!/usr/bin/env rspec

require "scc_api/hw_detection"

describe ".cpu_sockets" do
  it "returns CPU sockets number" do
    SccApi::HwDetection.should_receive(:'`').with("lscpu").and_return(File.read("test/fixtures/lscpu_1_socket.out"))
    returned = SccApi::HwDetection.cpu_sockets
    expect(returned).to eq(1), "Detected CPU sockets: '#{returned}'"
  end

  it "raises error when detection fails" do
    SccApi::HwDetection.should_receive(:'`').with("lscpu").and_return("")

    expect{SccApi::HwDetection.cpu_sockets}.to raise_error
  end
end

describe ".graphics_card_vendors" do
  it "returns graphics cards vendors" do
    SccApi::HwDetection.should_receive(:'`').with("lspci -n -vmm").and_return(File.read("test/fixtures/lspci_intel_gfx.out"))
    returned = SccApi::HwDetection.graphics_card_vendors
    expect(returned).to eq(["intel"]), "Detected graphics cards vendors: '#{returned}'"
  end

  it "returns no graphics cards vendors" do
    SccApi::HwDetection.should_receive(:'`').with("lspci -n -vmm").and_return(File.read("test/fixtures/lspci_no_gfx.out"))
    returned = SccApi::HwDetection.graphics_card_vendors
    expect(returned).to eq([]), "Detected graphics cards vendors: '#{returned}'"
  end
end
