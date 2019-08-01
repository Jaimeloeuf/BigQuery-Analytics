[{
    doc_ID: 'string',
    referral_code: 'string',
    payment_status: 'string',
    razer__channel: 'string',
    razer__skey: 'string',
    razer__appcode: 'string',
    razer__transaction_id: 'string',
    razer__status: 'string',
    razer__currency: 'string',
    created_at___seconds: 'number',
    created_at___nanoseconds: 'number',
    currency_code: 'string',
    shipping__mobile_number: 'string',
    shipping__city: 'string',
    shipping__state: 'string',
    shipping__email: 'string',
    shipping__postal_code: 'string',
    shipping__country: 'string',
    shipping__address_line1: 'string',
    shipping__country_dial_code: 'string',
    shipping__address_line2: 'string',
    total_amount: 'number',
    discounted_amount: 'number',
    ship_method__method_max_weight: 'number',
    ship_method__method_name: 'string',
    ship_method__method_price: 'number',
    ship_method__method_currency: 'string',
    ship_method__ship_method_id: 'string',
    ship_method__method_min_weight: 'number',
    ship_method__method_provider: 'string',
    modified_at___seconds: 'number',
    modified_at___nanoseconds: 'number',
    description: 'string'
}]

[{
        doc_ID: '1905151101372461551',
        created_at___seconds: 1557889326,
        created_at___nanoseconds: 656000000,
        currency_code: 'MYR',
        shipping__country_dial_code: '60',
        shipping__mobile_number: '4343535353',
        shipping__email: 'test111@pslove.com',
        shipping__country: 'Malaysia',
        collection_point__address: 'LOT NO 25, GROUND FLOOR,JALAN BESAR',
        collection_point__id: 'BnbjkofiBGosNsD5mJH1',
        collection_point__site_name: 'YONG PENG JOHOR',
        collection_point__region_name: 'Johor',
        total_amount: 101,
        discounted_amount: 519,
        ship_method__method_max_weight: 0.99,
        ship_method__method_name: 'Guardian Collection Point',
        ship_method__method_price: 0,
        ship_method__method_currency: 'MYR',
        ship_method__ship_method_id: 'wnNNc0C9ZyuPR83nGAmt',
        ship_method__method_min_weight: 0,
        ship_method__method_provider: 'Guardian',
        modified_at___seconds: 1557889326,
        modified_at___nanoseconds: 656000000,
        description: 'MenstruHeat (1RM)',
        referral_code: 'normal',
        payment_status: 'paid',
        razer__skey: 'b35c179e7909a11fac74c5cd30485a6d',
        razer__transaction_id: '30037083',
        razer__appcode: '',
        razer__status: '00',
        razer__currency: 'RM',
        razer__channel: 'FPX'
    }]

//set the project first
//bq show users_data_for_analytics__.orders
//bq update pslove-dev:users_data_for_analytics__.orders doc_ID:string,referral_code:string
//Removed fields collection_point__site_name:string,collection_point__region_name:string,collection_point__address:string,collection_point__id:string,
//share_code:string  only for prod


/*
bq update \
pslove-dev:users_data_for_analytics.orders \
doc_ID:string,user_doc_ID:string,referral_code:string,payment_status:string,razer__channel:string,razer__skey:string,razer__currency:string,razer__appcode:string,razer__transaction_id:string,\
shipping__address_line2:string,razer__status:string,created_at___seconds:integer,created_at___nanoseconds:integer,currency_code:string,shipping__address_line1:string,shipping__country_dial_code:string,\
shipping__mobile_number:string,shipping__city:string,shipping__state:string,shipping__email:string,shipping__country:string,\
total_amount:integer,discounted_amount:integer,ship_method__method_max_weight:numeric,ship_method__method_name:string,ship_method__method_price:integer,\
ship_method__method_currency:string,ship_method__ship_method_id:string,ship_method__method_min_weight:numeric,ship_method__method_provider:string,modified_at___seconds:integer,\
modified_at___nanoseconds:integer,description:string,shipping__postal_code:string,\
collection_point__site_name:string,collection_point__region_name:string,collection_point__address:string,collection_point__id:string,share_code:string
*/

/*
bq update \
pslove-usa:users_data_for_analytics.orders \
doc_ID:string,user_doc_ID:string,referral_code:string,payment_status:string,razer__channel:string,razer__skey:string,razer__currency:string,razer__appcode:string,razer__transaction_id:string,\
shipping__address_line2:string,razer__status:string,created_at___seconds:integer,created_at___nanoseconds:integer,currency_code:string,shipping__address_line1:string,shipping__country_dial_code:string,\
shipping__mobile_number:string,shipping__city:string,shipping__state:string,shipping__email:string,shipping__country:string,\
total_amount:integer,discounted_amount:integer,ship_method__method_max_weight:numeric,ship_method__method_name:string,ship_method__method_price:integer,\
ship_method__method_currency:string,ship_method__ship_method_id:string,ship_method__method_min_weight:numeric,ship_method__method_provider:string,modified_at___seconds:integer,\
modified_at___nanoseconds:integer,description:string,shipping__postal_code:string,\
collection_point__site_name:string,collection_point__region_name:string,collection_point__address:string,collection_point__id:string,share_code:string
*/