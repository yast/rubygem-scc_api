
# this is just an experimental code for writing /var/lib/suseRegister/registration-status.xml file
# see https://wiki.innerweb.novell.com/index.php/Registration#Add_Registration_Status_to_zmdconfig

require "rexml/document"

doc = REXML::Document.new
doc << REXML::XMLDecl.new("1.0", "UTF-8")

status = doc.add_element("status", "generated" => Time.now.to_i)

productstatus = status.add_element("productstatus", "product" => "SUSE_SLES",
  "version" => "12", "release" => "DVD", "arch" => "x86_64",
  "result" => "success", "errorcode" => "OK")

productstatus.add_element("subscription", "status" => "ACTIVE", "expiration" => Time.now.to_i, "type" => "EVALUATION")
productstatus.add_element("message").text = "OK"

xml = ""
doc.write(:output => xml, :indent => 2)
puts xml

# just some tree traversal...
#doc.elements.each("//productstatus") do |e|
#  puts "#{e.attributes["product"]} - #{e.elements["subscription"].attributes["status"]}"
#end
