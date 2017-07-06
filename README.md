# README

## Rails Type

This app uses Rails 5

## What Does It Do?

This app currently serves as a database for ST passengers. It allows for sorting, filtering, and searching passengers in the database. We’ve implemented a color code system so ST dispatchers can easily see which passengers are expired, about to expire, deactivated, or lack a needed doctor’s note. This app also has differing admin and non-admin views. A chron job runs every morning at 4:30am to deactivate expired passengers.

This app may later be expanded to serve other ST department needs, as well.
