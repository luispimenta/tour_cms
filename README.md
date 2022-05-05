# tourcms

A simple wrapper for connecting to [TourCMS Marketplace API](http://www.tourcms.com/support/api/mp/). This wrapper mirrors the TourCMS PHP library.

## Install

	gem install tour_cms_api

## Usage

Using the library is as simple as creating a **TourCMS::Connection** object:

	conn = TourCMS::Connection.new(marketplace_id, private_key, result_type)

Your Marketplace ID and Private Key can be found in the TourCMS Partner Portal. The result type can be one of **hash** or **raw** where **raw** will return the raw XML from the API and **hash** will return a Ruby Hash of the result.

### Working with your connection in Raw mode

	# Instantiate the connection
	conn = TourCMS::Connection.new("12345", "mydeepsecret", "raw")
	# Check we're working
	conn.api_rate_limit_status
	=> "<?xml version="1.0" encoding="utf-8" ?><response><request>GET /api/rate_limit_status.xml</request>
		<error>OK</error><remaining_hits>1999</remaining_hits><hourly_limit>2000</hourly_limit></response>"
	# List the channels we have access to
	conn.list_channels
	=> "<?xml version="1.0" encoding="utf-8" ?><response><request>GET /p/channels/list.xml</request>
		<error>OK</error><channel>(...)</channel><channel>(...)</channel><channel>(...)</channel></response>"
	# Show a particular channel
	conn.show_channel(1234567)
	=> "<?xml version="1.0" encoding="utf-8" ?><response><request>GET /p/channels/list.xml</request>
		<error>OK</error><channel>(...)</channel></response>"

### Working with your connection in Hash mode

	# Instantiate the connection
	conn = TourCMS::Connection.new("12345", "mydeepsecret", "hash")
	# Check we're working
	obj = conn.api_rate_limit_status
	=> {:request=>"GET /api/rate_limit_status.xml", :remaining_hits=>1999, :error=>"OK", :hourly_limit=>2000}
	obj[:hourly_limit]
	=> 2000
	# List the channels we have access to
	obj = conn.list_channels
	=> {Hash of all connected TourCMS channels and their properties}
	# See how many TourCMS channels you're connected to.
	obj['channel'].count
	=> 100
	obj['channel'].first['channel_name']
	=> "My Adventure Tour Operator"
	# Show a particular channel
	obj = conn.show_channel(1234567)
	obj[:channel][:channel_id]
	=> "1234567"
	# Search for all tours in GB
	obj = conn.search_tours({:country => "PT", :per_page => "10", :page => "1"})
	obj['tour'].first['tour_name']
	=> "Canyoning"


### Passing parameters

Many TourCMS methods accept parameters. Most methods take a hash of parameters like so:

	obj = conn.search_tours({:country => "PT", :per_page => "10", :page => "1"})

## List of functions in TourCMS::Connection

*	api\_rate\_limit\_status
*	list\_channels
*	show\_channel
*	search\_tours
*	search\_hotels\_range
*	search\_hotels\_specific
*	list\_tours
*	list\_tour\_images
*	show\_tour
*	show\_tour\_departures
*	show\_tour\_freesale
*	check\_tour\_availability
*	booking\_start\_new
*	booking\_commit\_new

## Dependencies

This gem depends on ActiveSupport 3.0.0+

## Contributing to tourcms

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

See LICENSE.txt for further details.
