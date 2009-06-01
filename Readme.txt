This is a collection of libraries and command line tools written in
Ruby for using and manipulating the WURFL.

Environment:
These tools are run on Ruby 1.6.8 and Ruby 1.8 builds, but it is
possible that it will work on other versions.  If you are using Ruby
1.6 then you will need to download REXML from
http://raa.ruby-lang.org/list.rhtml?name=rexml




Installing:
Until an installer is written, it is best to make a symbolic link in
your site_ruby directory called wurfl that points the directory that
holds the wurflhandset.rb file.
This is typically in /usr/lib/ruby/site_ruby/1.6/ or
/usr/local/lib/ruby/site_ruby depending upon your ruby installation.


Applications:

wurflloader.rb
Is used to parse and load a WURFL XML file into memory or save a
PStore database that is used by most of the other tools.  This
application creates WURFL PStore databases that are essential for use
with the other Ruby applications.


wurflinspector.rb
Is a tool that will let you do various searches and queries on the
WURFL.  This is a very simple, yet powerful program for finding
information about the handsets in the WURFL.  See the wurflinspector
examples section for usage.


wurflsanitycheck.rb
Is a partial WURFL validating program.  It does a few simple
checks to make sure the XML structure is parse-able by the wurflloader.
If you receive loading errors by the wurflloader, then you can run the
wurflsanitycheck program to find the lines in the XML file that might
be causing the problem.


wurflcomparator.rb
Is a another simple program that will find the differences from two
WURFL Ruby PStore databases. This is another way of finding changes
from the different versions of the WURFL without running a diff on the
XML files.

uaproftowurfl.rb
Is a program that takes UAProfiles and creates an equivalent WURFL
entry.  It holds all of the mappings used to convert a UAProfile to a
WURFL entry.  This program alone makes using the Ruby tools worth it.

uaprofwurflcomparator.rb
Is a program that compares UAProfiles against the equivalent WURFL
entries. It takes a file that contains an UAProfile URL and an
User-Agent per line, in addition to a Ruby Wurfl PStore database. It
then compares the UAProfile against the Wurfl that matches the same
User Agent.  The output is a list of the differences and a WURFL
formatted entry showing the differences.



Library Files:
wurflhandset.rb
Is the Ruby class representation of a WURFL handset.  It is the core
of the Ruby WURFL tools.

wurflutils.rb
Is a module that handles the loading and saving of WURFL handsets in a
Ruby PStore database. 


WURFLINSPECTOR Examples:

The command below will search through all handsets and return the ids
of handsets that match the passed Ruby boolean evaluation
*) This command will return all handsets that have more than 2 colors.
"wurflinspector.rb -d pstorehandsets.db -s '{ |hand| hand["colors"].to_i > 2 }'"
The Ruby query must go in between the single quote marks and needs to
declare the WurflHandset instance variable name.

*) This command shows you how you can cheat with the current design of
the wurflinspector and print more user friendly results.  This example
assumes you have the command line programs sort and uniq, but that is
only to make the output look better. This example does the same as the
above, except that it prints out the brand name and model name of the
matching handsets instead of the WURFL id.

Note: this should all go into one command line call
"wurflinspector.rb -d pstorehandsets.db -s '{|hand| puts
"#{hand["brand_name"]} #{hand["model_name"]}" if hand["colors"].to_i >
2}' | sort | uniq"


The following individual handset query commands will tell the value of
capabilities and from where it obtained the setting.

*) A command to query the handset with the id sonyericsson_t300_ver1
for all of its' capabilities:
"wurflinspector.rb -d pstorehandsets.db -i sonyericsson_t300_ver1"

*) A command to query the handset with the id sonyericsson_t300_ver1 for
backlight capability:
"wurflinspector.rb -d pstorehandsets.db -i sonyericsson_t300_ver1 -q
backlight"


UAPROFTOWURFL Details:

The mappings are not fully complete and can certainly use your input
in improving them.

About the source code:
The main piece of code to read are the methods under the 
"UAProfile Mappings" comment.

For now you can ignore the details above this comment.
Basically each method is the name of a UAProfifle component.
When you parse a UAProfile file it will call each UAProfile
component's method name.  

So you can simply look at UAProfile component's method to see 
how it maps to the WURFL.
If a component is not found as a method it will be logged to 
Standard Error.  For this log one can then add the method to
the UAProfToWurfl class later.


How to use:

A simple usage is:
ruby uaproftowurfl.rb sampleprofile.xml


Example use from a bash shell with many profiles:

for i in `ls profiles`; do 
	ruby uaproftowurfl.rb profiles/$i >output/$i.wurfl 
	2> output/$i.parser.err; 
done

This assumes that you have a profiles directory with all of the UAProf
file you wish to parse and a output directory to place the results and
errors.


UAPROFWURFLCOMPARATOR usage:

You pass the program a directory to save the UAProfile files taken
from the given URL, a file that holds the UAProfil URL and User-Agent
mappings, and the Ruby PStore database that holds the WURFL. 

The following is a simple example of execution
uaprofwurflcomparator.rb -d ./profiles -f all-profile.2003-08.log -c -w wurfl.db

