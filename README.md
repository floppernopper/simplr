## Social Maya

Social Maya, a free and open source social network, and intentional digital community for artists and philosophers.

This is free and open source software, as specified above by the GNU General Public License.

## Setting up Social Maya server

1. Download the package or clone the repo.
2. Install Ruby version 2.2 using RVM or the Ruby Installer
3. Install ImageMagick: `sudo apt-get install imagemagick libmagickwand-dev`
4. Install Ruby gems: `bundle install`
5. Setup the database: `bundle exec rake db:setup`
6. Run the database migrations: `bundle exec rake db:migrate`

The default database is SQLite3.
