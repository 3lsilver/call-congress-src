CallCongress.net
================
This is the source code that power CallCongress.net, an entry into the Sunlight Foundation's "Apps for America" contest.

More info here: http://www.sunlightlabs.com/appsforamerica/

This source code is licensed under the Apache 2.0 license. See LICENSE for more details.

Email callcongress.net@gmail.com with questions, bug reports or feature requests.

SETUP
================
1. Edit settings.yaml.example with your site, asterisk and adhearsion settings

2. Rename it to settings.yaml (and leave it in app root directory)

[TODO] - need to modularize code and better document how to use this source code for a different site

Requirements
================
  Adhearsion: 
    sudo gem install adhearsion

  Asterisk:
    http://asterisk.org

  Datamapper:
    sudo gem install dm-core dm-validations dm-aggregates
    
  Sinatra
    sudo gem install sinatra

  Json
    sudo gem install json
    
  Haml/Sass
    sudo gem install haml
    
  Drb
    sudo gem install drb


TODO
================
-- Add calling campaigns:
   Allow users to create "call campaigns" with targeted legislators, talking points and a unique home page for the campaign. This is a bigger project and didn't make it into the launch but it will be a killer feature once it is implemented.

-- Add followup calls:
   Allow users to followup on calls from each other to create a threaded dialogue with a congressional office
