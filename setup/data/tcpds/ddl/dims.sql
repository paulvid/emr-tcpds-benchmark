create database if not exists tpcds_orc_10000;
use tpcds_orc_10000;
-- Table<inventory (4 cols)>

drop table if exists inventory;
create external table if not exists inventory(
      inv_date_sk bigint
,     inv_item_sk bigint
,     inv_warehouse_sk bigint
,     inv_quantity_on_hand int
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/inventory';

-- Table<store (29 cols)>

drop table if exists store;
create external table if not exists store(
      s_store_sk bigint
,     s_store_id char(16)
,     s_rec_start_date date
,     s_rec_end_date date
,     s_closed_date_sk bigint
,     s_store_name varchar(50)
,     s_number_employees int
,     s_floor_space int
,     s_hours char(20)
,     S_manager varchar(40)
,     S_market_id int
,     S_geography_class varchar(100)
,     S_market_desc varchar(100)
,     s_market_manager varchar(40)
,     s_division_id int
,     s_division_name varchar(50)
,     s_company_id int
,     s_company_name varchar(50)
,     s_street_number varchar(10)
,     s_street_name varchar(60)
,     s_street_type char(15)
,     s_suite_number char(10)
,     s_city varchar(60)
,     s_county varchar(30)
,     s_state char(2)
,     s_zip char(10)
,     s_country varchar(20)
,     s_gmt_offset decimal(5,2)
,     s_tax_percentage decimal(5,2)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/store';

-- Table<call_center (31 cols)>

drop table if exists call_center;
create external table if not exists call_center(
      cc_call_center_sk bigint
,     cc_call_center_id char(16)
,     cc_rec_start_date date
,     cc_rec_end_date date
,     cc_closed_date_sk bigint
,     cc_open_date_sk bigint
,     cc_name varchar(50)
,     cc_class varchar(50)
,     cc_employees int
,     cc_sq_ft int
,     cc_hours char(20)
,     cc_manager varchar(40)
,     cc_mkt_id int
,     cc_mkt_class char(50)
,     cc_mkt_desc varchar(100)
,     cc_market_manager varchar(40)
,     cc_division int
,     cc_division_name varchar(50)
,     cc_company int
,     cc_company_name char(50)
,     cc_street_number char(10)
,     cc_street_name varchar(60)
,     cc_street_type char(15)
,     cc_suite_number char(10)
,     cc_city varchar(60)
,     cc_county varchar(30)
,     cc_state char(2)
,     cc_zip char(10)
,     cc_country varchar(20)
,     cc_gmt_offset decimal(5,2)
,     cc_tax_percentage decimal(5,2)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/call_center';

-- Table<catalog_page (9 cols)>

drop table if exists catalog_page;
create external table if not exists catalog_page(
      cp_catalog_page_sk bigint
,     cp_catalog_page_id char(16)
,     cp_start_date_sk bigint
,     cp_end_date_sk bigint
,     cp_department varchar(50)
,     cp_catalog_number int
,     cp_catalog_page_number int
,     cp_description varchar(100)
,     cp_type varchar(100)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/catalog_page';

-- Table<web_site (26 cols)>

drop table if exists web_site;
create external table if not exists web_site(
      web_site_sk bigint
,     web_site_id char(16)
,     web_rec_start_date date
,     web_rec_end_date date
,     web_name varchar(50)
,     web_open_date_sk bigint
,     web_close_date_sk bigint
,     web_class varchar(50)
,     web_manager varchar(40)
,     web_mkt_id int
,     web_mkt_class varchar(50)
,     web_mkt_desc varchar(100)
,     web_market_manager varchar(40)
,     web_company_id int
,     web_company_name char(50)
,     web_street_number char(10)
,     web_street_name varchar(60)
,     web_street_type char(15)
,     web_suite_number char(10)
,     web_city varchar(60)
,     web_county varchar(30)
,     web_state char(2)
,     web_zip char(10)
,     web_country varchar(20)
,     web_gmt_offset decimal(5,2)  
,     web_tax_percentage decimal(5,2)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/web_site';

-- Table<web_page (14 cols)>

drop table if exists web_page;
create external table if not exists web_page(
      wp_web_page_sk bigint
,     wp_web_page_id char(16)
,     wp_rec_start_date date
,     wp_rec_end_date date
,     wp_creation_date_sk bigint
,     wp_access_date_sk bigint
,     wp_autogen_flag char(1)
,     wp_customer_sk bigint
,     wp_url varchar(100)
,     wp_type char(50)
,     wp_char_count int
,     wp_link_count int
,     wp_image_count int
,     wp_max_ad_count int
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/web_page';

-- Table<warehouse (14 cols)>

drop table if exists warehouse;
create external table if not exists warehouse(
      w_warehouse_sk bigint
,     w_warehouse_id char(16)
,     w_warehouse_name varchar(20)
,     w_warehouse_sq_ft int
,     w_street_number char(10)
,     w_street_name varchar(60)
,     w_street_type char(15)
,     w_suite_number char(10)
,     w_city varchar(60)
,     w_county varchar(30)
,     w_state char(2)
,     w_zip char(10)
,     w_country varchar(20)
,     w_gmt_offset decimal(5,2)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/warehouse';

-- Table<customer (18 cols)>

drop table if exists customer;
create external table if not exists customer(
      c_customer_sk bigint
,     c_customer_id char(16)
,     c_current_cdemo_sk bigint
,     c_current_hdemo_sk bigint
,     c_current_addr_sk bigint
,     c_first_shipto_date_sk bigint
,     c_first_sales_date_sk bigint
,     c_salutation char(10)
,     c_first_name char(20)
,     c_last_name char(30)
,     c_preferred_cust_flag char(1)
,     c_birth_day int
,     c_birth_month int
,     c_birth_year int
,     c_birth_country varchar(20)
,     c_login char(13)
,     c_email_address char(50)
,     c_last_review_date_sk bigint
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/customer';

-- Table<customer_address (13 cols)>

drop table if exists customer_address;
create external table if not exists customer_address(
      ca_address_sk bigint
,     ca_address_id char(16)
,     ca_street_number char(10)
,     ca_street_name varchar(60)
,     ca_street_type char(15)
,     ca_suite_number char(10)
,     ca_city varchar(60)
,     ca_county varchar(30)
,     ca_state char(2)
,     ca_zip char(10)
,     ca_country varchar(20)
,     ca_gmt_offset decimal(5,2)
,     ca_location_type char(20)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/customer_address';

-- Table<customer_demographics (9 cols)>

drop table if exists customer_demographics;
create external table if not exists customer_demographics(
      cd_demo_sk bigint
,     cd_gender char(1)
,     cd_marital_status char(1)
,     cd_education_status char(20)
,     cd_purchase_estimate int
,     cd_credit_rating char(10)
,     cd_dep_count int
,     cd_dep_employed_count int
,     cd_dep_college_count int
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/customer_demographics';

-- Table<date_dim (28 cols)>

drop table if exists date_dim;
create external table if not exists date_dim(
      d_date_sk bigint
,     d_date_id char(16)
,     d_date date
,     d_month_seq int
,     d_week_seq int
,     d_quarter_seq int
,     d_year int
,     d_dow int
,     d_moy int
,     d_dom int
,     d_qoy int
,     d_fy_year int
,     d_fy_quarter_seq int
,     d_fy_week_seq int
,     d_day_name char(9)
,     d_quarter_name char(6)
,     d_holiday char(1)
,     d_weekend char(1)
,     d_following_holiday char(1)
,     d_first_dom int
,     d_last_dom int
,     d_same_day_ly int
,     d_same_day_lq int
,     d_current_day char(1)
,     d_current_week char(1)
,     d_current_month char(1)
,     d_current_quarter char(1)
,     d_current_year char(1)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/date_dim';

-- Table<household_demographics (5 cols)>

drop table if exists household_demographics;
create external table if not exists household_demographics(
      hd_demo_sk bigint
,     hd_income_band_sk bigint
,     hd_buy_potential char(15)
,     hd_dep_count int
,     hd_vehicle_count int
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/household_demographics';

-- Table<item (22 cols)>

drop table if exists item;
create external table if not exists item(
      i_item_sk bigint
,     i_item_id char(16)
,     i_rec_start_date date
,     i_rec_end_date date
,     i_item_desc varchar(200)
,     i_current_price decimal(7,2)
,     i_wholesale_cost decimal(7,2)
,     i_brand_id int
,     i_brand char(50)
,     i_class_id int
,     i_class char(50)
,     i_category_id int
,     i_category char(50)
,     i_manufact_id int
,     i_manufact char(50)
,     i_size char(20)
,     i_formulation char(20)
,     i_color char(20)
,     i_units char(10)
,     i_container char(10)
,     i_manager_id int
,     i_product_name char(50)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/item';

-- Table<income_band (3 cols)>

drop table if exists income_band;
create external table if not exists income_band(
      ib_income_band_sk bigint
,     ib_lower_bound int
,     ib_upper_bound int
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/income_band';

-- Table<promotion (19 cols)>

drop table if exists promotion;
create external table if not exists promotion(
      p_promo_sk bigint
,     p_promo_id char(16)
,     p_start_date_sk bigint
,     p_end_date_sk bigint
,     p_item_sk bigint
,     p_cost decimal(15,2)
,     p_response_target int
,     p_promo_name char(50)
,     p_channel_dmail char(1)
,     p_channel_email char(1)
,     p_channel_catalog char(1)
,     p_channel_tv char(1)
,     p_channel_radio char(1)
,     p_channel_press char(1)
,     p_channel_event char(1)
,     p_channel_demo char(1)
,     p_channel_details varchar(100)
,     p_purpose char(15)
,     p_discount_active char(1)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/promotion';

-- Table<reason (3 cols)>

drop table if exists reason;
create external table if not exists reason(
      r_reason_sk bigint
,     r_reason_id char(16)
,     r_reason_desc char(100)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/reason';

-- Table<ship_mode (6 cols)>

drop table if exists ship_mode;
create external table if not exists ship_mode(
      sm_ship_mode_sk bigint
,     sm_ship_mode_id char(16)
,     sm_type char(30)
,     sm_code char(10)
,     sm_carrier char(20)
,     sm_contract char(20)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/ship_mode';

-- Table<time_dim (10 cols)>

drop table if exists time_dim;
create external table if not exists time_dim(
      t_time_sk bigint
,     t_time_id char(16)
,     t_time int
,     t_hour int
,     t_minute int
,     t_second int
,     t_am_pm char(2)
,     t_shift char(20)
,     t_sub_shift char(20)
,     t_meal_time char(20)
)
stored as orc
location 's3://manowar-perf-dw-raw-data/benchmark/tpcds_orc_10000.db/time_dim';

