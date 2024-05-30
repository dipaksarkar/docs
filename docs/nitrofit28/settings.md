---
titleTemplate: NitroFIT28
---

# Settings

Here you can configure your timezone and date formatting that will apply to all of the control panel.

**Available Fields**
-   `Company name` - Appears on your website
-   `Email` - This is the default email address that will appear as the sender on all of the email that sends to you and your customers.
-   `Phone` - Contact number associated with your business.
-   `Country` - Location of your business.
-   `Timezone` - Time zone setting for your control panel.
-   `Language` - Language preference for your control panel.
-   `Currency` - Currency used for transactions and invoices. Cannot be changed after the first sale.
-   `Selling product online?` - Indicates whether your business sells products online. Disabling this disables the shop feature in the app.
-   `Logo` - Appears on your website and invoices

## Opening Times

The Opening Times section outlines the precise hours when our gym is open and closed. Stay updated on our daily schedule to plan your workouts accordingly.

**Steps to Updating Opening Times:**

1.  From your admin, go to Settings > Opening Times.
2.  Click on clock and set your time
3.  Click on `save icon` to save the changes

Now you can see that changes on https://your-domain.com/opening-times

## Billing Information

The Billing Information section serves as the hub for managing crucial details regarding your gym's legal identity. Here, you can input and update the legal business name and address, which are essential components for generating accurate and professional invoices. Additionally, this information seamlessly integrates into email footers, ensuring that all communications maintain a polished and legally compliant appearance. Keeping this information up-to-date in the Billing Information section guarantees accuracy in financial transactions and reinforces your gym's commitment to transparency and professionalism.

**Available Fields**
-   `Legal business name` - Will be appear on Invoice.
-   `Address line 1` - Primary address line.
-   `Address line 2` - Secondary address line (optional).
-   `Country/region` - Location of the business.
-   `City` - City where the business is located.
-   `State` - State or province where the business is located.
-   `Postal code` - Postal code for the business location.

**Steps to Updating Billing:**

1.  From your admin, go to Settings > Billing Information.
2.  Update Billing Information.
3.  Click on `Save`.


## Homepage Banner

The Banners section is your dynamic canvas for capturing attention and promoting special offers on the home page. Here, you can effortlessly manage the home page slider to feature eye-catching banners that highlight special promotions and actionable items. Whether it's a limited-time discount, a new class introduction, or an exclusive membership offer, this section empowers you to curate a visually engaging and compelling display. Utilize the Banners section to captivate your audience, drive user engagement, and effectively communicate the exciting opportunities your gym has to offer.

**Steps to Updating Banner:**

1.  From your admin, go to Settings > Banners.
2.  Click on plus icon to add new banner Or Click on edit icon to editing the banner.
3.  Update your banner info
4.  Click `Done`.

## Documents

The Documents section is your centralized repository for managing essential files within both the frontend and members area. From informative guides and policy documents for public access to exclusive member resources, this section streamlines document organization and accessibility. Easily upload, update, and categorize files to ensure seamless access for both the general audience and members. Whether it's sharing fitness guides with the public or providing exclusive content to members, the Documents section empowers efficient document management for a well-informed and engaged user community.

**Steps to Updating Documents:**

1.  From your admin, go to Settings > Documents.
2.  Click on thumbnail to editing the banner.
3.  Select your docments
4.  Click `Done`.


## Locations
A location is any physical place or an app where you do any or all of the following activities:

-   sell products
-   manage plan & subscription
-   stock inventory

You can set up multiple locations in your store so that you can track inventory and fulfill orders at your locations. Your locations can be retail stores, warehouses, or any other place where you manage or stock inventory. With multiple locations, you have better visibility into your inventory across your business.

[Setting up your locations](/nitrofit28/settings/locations)

## Payments
Make sure that you understand the payment process. When a customer checks out, they can choose to pay for their order using any of the methods that you've activated in the Payment providers area of your admin. You can activate a variety of payment methods.

There are a few different things to consider when you're choosing which payment methods to offer. If you want to let your customers pay using a credit card, then you can use Stripe Payments or a third-party provider.

There are also several ways for customers to pay online without using a credit card, such as PayPal, Razorpay, Amazon Pay, and Apple Pay.

**In this section**

-   [Setting up your payments](/nitrofit28/settings/payments)
-   [Stripe](/nitrofit28/settings/payments.html#setup-stripe)
-   Razorpay (Coming soon...)
-   PayPal Express (Coming soon...)
-   Third-party payment providers (Coming soon...)
-   Additional payment methods
-   Manual payment methods


## Notification Templates
Notification templates allow you to customise the messages that go out to your customers when actions occur inside `NitroFIT28`. You can customize every email that goes out to a customer here.

You can access this feature at Settings > Notification Templates.

[Setting up your notification](/nitrofit28/settings/notifications)


##  Taxes
You might need to charge taxes on your sales, and then report and remit those taxes to your government. Although tax laws and regulations are complex and can change often, you can set up NitroFIT28 to automatically handle most common sales tax calculations. You can also set up tax overrides to address unique tax laws and situations.

You can access this feature at Settings > Taxes.

[Setting up your taxes](/nitrofit28/settings/taxes)

## [Whatsapp and Push] Notifications

Prerequisites
-   `Set up a Firebase Project` - An active Firebase project. If you haven’t already created one, head over to the Firebase Console (https://console.firebase.google.com/) and create a new project.
-   `Set up a Twilio Account` - First, you need to sign up for a Twilio account (if you don’t have one already) at https://www.twilio.com/try-twilio. After creating an account, you’ll get your Account SID and Auth Token, which are essential for API authentication.

**Enable Push Notification**

1. Navigate to the Firebase Console, select your project, and go to `Project Settings > Service` accounts. Generate a new private key and download the JSON file containing your service account credentials.
2. Place this JSON file in your hosting `public_html/storage/firebase-credentials.json`.
3. From your admin, go to `Settings > Push/Whatsapp Alert`.
4. Check the box labeled `App Push Notification`.
5. Click `Save`.
  
**Enable Whatsapp Notification**

1. From your admin, go to `Settings > Push/Whatsapp Alert`.
2. Check the box labeled `Whatsapp Notification`.
3. Fill Twillo Sid, Twillo Token, and Sender
4. Click `Save`.