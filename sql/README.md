# Matajir Database Setup

This directory contains SQL scripts to set up and populate the Matajir database.

## Files

- `init_database.sql`: Creates all necessary tables with the updated schema (using keywords instead of address)
- `sample_data.sql`: Populates the database with sample data for testing
- `update_schema.sql`: Updates an existing database to replace the address field with keywords

## How to Use

### Setting Up a New Database

When starting your project from scratch, follow these steps:

1. Create a new database in Supabase or your PostgreSQL server
2. Run the `init_database.sql` script to create all tables
3. Run the `sample_data.sql` script to populate the database with sample data

### Using with Supabase

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Create a new query
4. Copy and paste the contents of `init_database.sql`
5. Run the query
6. Create another query with the contents of `sample_data.sql`
7. Run the query

### Updating an Existing Database

If you have an existing database with the old schema (using address instead of keywords):

1. Run the `update_schema.sql` script to update the schema

## Database Schema

The database uses the following tables:

- `profiles`: User profiles
- `categories`: Product categories and subcategories
- `stores`: Store information (with keywords for search)
- `store_banners`: Store banner images
- `store_categories`: Many-to-many relationship between stores and categories
- `favorites`: User favorite stores
- `advertisements`: Advertisements
- `advertisement_categories`: Many-to-many relationship between advertisements and categories

## Key Changes

The main change in this schema is replacing the `address` field with `keywords` in the `stores` table. This allows for better search functionality, as the app can now search through both store names and keywords.

## Search Functionality

The schema includes text search indexes on both the `name` and `keywords` columns in the `stores` table, which enables efficient searching through both fields.
