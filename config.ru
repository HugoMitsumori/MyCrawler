# This file is used by Rack-based servers to start the application.
require 'rack/iframe'
require_relative 'config/environment'
use Rack::Iframe

run Rails.application
