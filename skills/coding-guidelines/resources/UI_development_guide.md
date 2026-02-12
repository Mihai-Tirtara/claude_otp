

[**HOME**](Home) » [**Guidelines**](Guidelines) » [**UI Development Guide**](/Guidelines/UI-Development-Guide)


***

## Overview
This page gives an overview about how user interfaces should be built in OTP and also some useful tips.

### Bootstrap
The OTP team decided to use bootstrap on every new page and the old pages will be migrated to bootstrap with the time. Bootstrap has a lot of advantages:

- modern look and feel
- not necessary to write many global styles
- contains common used components
- easy to use
- responsive design
- very good documented (https://getbootstrap.com/docs/4.6/)

### Layouts

There are two layouts available in OTP:

1. **application** (bootstrap)
   
   This layout is enabled per default. It contains the libraries which are required for the Bootstrap pages. 
   Those libraries can be found in `grails-app/assets/javascripts/modules/application.js` and 
   `grails-app/assets/stylesheets/modules/application.css`
   

2. **main** (old, deprecated)

    This is the old layout which is deprecated and should not be used anymore on new pages. It can be disabled by removing `<meta name="layout" content="main"/>` in the html header of the specific `*.gsp` file.

### UI Dependencies
The following UI dependencies are available in OTP.

| Dependency      | Version | Layout                             | Info                                                                                                                     |
|-----------------|---------|------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| Bootstrap       | 4.6.0   | application            |                                                                                                                          |
| Bootstrap Icons | 1.4.0   | application            |                                                                                                                          |
| Datatables      | 1.10.23 | application main (old) | Should be updated, then the bootstrap layout can be activated. But it requires jQuery 3.5, which needs to be done first. |
| jQuery          | 1.11.1  | application main (old) | Deprecated Should be updated to 3.5 soon                                                                                 |
| jQuery UI       | 1.10.4  | main (old)                         | Deprecated                                                                                                               |
| Select2         | 4.0.12  | application main(old)  |                                                                                                                          |

## Custom Styles

In OTP you can write custom CSS. Please take care of the following guidelines.

### Global Styles

The two files `otp.less` and `bootstrapped.less` are used to define global stylesheets. The `otp.less` is included in both layouts and the `bootstrapped.less` only in the application layout.

### Local Styles

Local styles are available for only one specific page. They are included in the gsp header of the page and the styles are stored in a less file `assets/stylesheets/pages/PAGENAME/FILENAME.less`

Example:

    <head>
        ...
        <asset:stylesheet src="pages/PAGENAME/FILENAME.less"/>
    </head>

### Dos and Don'ts

- write custom css only if there is no fitting class in the bootstrap library
- use global styles only if they are useful in a global context
- don't add styles to the `otp.less`, it is deprecated
- don't use html tags as css selectors
- don't use IDs as css selectors
- use self-explanatory class names
- use the color variables defined in the `colors.less`, which is imported
- if you find dead styles, remove it (be careful if they are used by jQuery selectors)

## Icons

In the application layout are the Bootstrap icons included. So it's very easy to integrate icons not necessary anymore to upload icon images into the assets directory.

List of all available icons: https://icons.getbootstrap.com/

There are different methods to include the icons. In OTP we use the font method. With this method it is only necessary to call the icon css class.

**Example:**

    <i class="bi bi-alarm-fill"></i>

## Message Handling

Old OTP pages are using the flash messages which comes within Grails. Flash messages have the disadvantage that a page reload is required. To prevent this new methods should be REST-like and return JSON objects or http error codes. In the case an error occurs, otp can send a toast message.

### Flash Message Templates

For pages that still use server-side flash messages (e.g. form submissions with redirects), there are two GSP templates:

| Template | Path | Layout | Status |
|----------|------|--------|--------|
| `/templates/messages` | `views/templates/_messages.gsp` | main (old) | Deprecated |
| `/layouts/messages` | `views/layouts/_messages.gsp` | application (Bootstrap) | Current |

Pages using the **application** layout must use `/layouts/messages`:

    <g:render template="/layouts/messages"/>

The old `/templates/messages` uses `info-box` CSS classes that are not styled under the Bootstrap layout.

### JavaScript Toast Messages

A toast message can be triggered out of every JavaScript method inside OTP.

**Examples:**

     $.otp.toaster.showInfoToast("Info Title", "Info message...");

     $.otp.toaster.showSuccessToast("Success Title", "Success message...");

     $.otp.toaster.showWarningToast("Warning Title", "Warning message...");

     $.otp.toaster.showErrorToast("Error Title", "Error message...");

**Example with ajax context:**

      $.ajax({
         url: $.otp.createLink({
               controller: 'demoController',
               action: 'demoAction',
         }),
         dataType: 'json',
         type: 'POST',
         data: {
            param1: value1,
            param2: value2
         },
         success: function () {
            $.otp.toaster.showSuccessToast("Operation successful", "The post method returned a 200 OK response.");
         },
         error: function (error) {
            if (error && error.responseJSON && error.responseJSON.message) {
               $.otp.toaster.showErrorToast("Operation failed")", "The post method returned a HTTP error status code. The message is " + error?.responseJSON?.message)
            } else {
               $.otp.toaster.showErrorToast("Operation failed", "Unknown error.");
            }
         }
      });

