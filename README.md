# News Reader

## Overview

News Reader is an iOS application designed to fetch and display dynamic news articles, offering features like voice synthesis of articles, image loading with caching, and integration with various services like AWS Polly for text-to-speech functionality.

The app uses pagination to load articles dynamically, integrates SDWebImage for efficient image loading and caching, and stores user preferences and cached data locally using Core Data. Additionally, the app adapts to both light and dark modes using dynamic colors to provide a visually appealing experience.

## Features

- **Dynamic Feed**: Fetches news articles dynamically based on user scrolling behavior.
- **Voice Synthesis**: Uses AWS Polly to synthesize article summary into speech for hands-free reading.
- **Image Loading & Caching**: Efficiently loads and caches article images using SDWebImage.
- **Dark Mode Support**: Adapts UI colors for both light and dark mode.
- **Core Data Integration**: Caches articles and related data for offline use.
- **Subscription Support**: Handles varying page sizes based on the user's subscription model.
- **Asynchronous Data Fetching**: Fetches data asynchronously to maintain a smooth user experience.
- **Caching**: Utilizes caching for both API and local data to improve performance.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ganapathy-shan/News-Reader.git
   
2.  **Install dependencies using CocoaPods**:

    -   Make sure you have [CocoaPods](https://cocoapods.org/) installed. If not, you can install it using:

        bash

        Copy code

        `sudo gem install cocoapods`

    -   Navigate to the project directory and run:

        bash

        Copy code

        `pod install`

3.  **Open the project**:

    -   Open the `.xcworkspace` file in Xcode:

        `open NewsReader.xcworkspace`

## Configure API and AWSPolly

### 1\. OpenAI API Key

**How to Get:**

1.  Visit the OpenAI website: <https://platform.openai.com/signup>.
2.  Sign up for an account or log in if you already have one.
3.  Go to the **API Keys** section from your account settings: OpenAI API Keys.
4.  Click **Create new secret key**.
5.  Copy the generated API key.

* * * * *

### 2\. NewsAPI Key

**How to Get:**

1.  Visit the NewsAPI website: <https://newsapi.org/>.
2.  Sign up for an account or log in if you already have one.
3.  Go to the **API Keys** section.
4.  Click **Get API Key** and copy the key.

**Where to Replace in Code:**

-   These keys will be placed in the `config.plist` file (explained in Step 4).

* * * * *

### 3\. Steps to Configure IAM Role for Full Polly Access

#### Create a New IAM Role in AWS Console:

1.  Go to the **IAM Console**: [AWS IAM Console](https://aws.amazon.com/iam/).
2.  On the left-hand side, select **Roles**.
3.  Click **Create role**.
4.  For the trusted entity, select **Cognito** as the service that will use this role.
5.  Under **Use case for the role**, choose **Cognito Identity Pool**.
6.  Click **Next: Permissions**.

#### Attach Polly Permissions to the Role:

1.  In the permissions search box, search for **Polly**.
2.  From the list, select **AmazonPollyFullAccess**.
3.  Click **Next: Tags**, then **Next: Review**.
4.  Give the role a meaningful name like **CognitoPollyFullAccessRole**.
5.  Click **Create role**.

#### Assign the Role to the Cognito Identity Pool:

1.  Go to the **Amazon Cognito Console**: [AWS Cognito Console](https://aws.amazon.com/cognito/).
2.  Select **Manage Identity Pools** from the navigation.
3.  Choose the **Identity Pool** you want to assign the role to.
4.  In the **Identity Pool settings**, click **Edit Identity Pool**.
5.  Under **Authentication Providers**, select the role **CognitoPollyFullAccessRole** for both Authenticated and Unauthenticated Role.
6.  Click **Save Changes**.

* * * * *

### 4\. Create `config.plist` in Xcode and Add API Keys

#### Steps to Create the `config.plist` File:

1.  Open your project in **Xcode**.
2.  In the **Project Navigator**, right-click on the **"News Reader"** folder.
3.  Select **New File...**.
4.  Choose **Property List** under the **iOS > Resource** category.
5.  Name the file `config.plist` and click **Create**.

#### Add Keys:

Create 3 rows in `config.plist` with following keys
**OpenAPIKey**
**NewsAPIKey**
**AWSPoolID**

#### Update the Key Values:

-   Replace the `value` for:
    -   **OpenAPIKey**: Paste the OpenAI API key.
    -   **NewsAPIKey**: Paste the NewsAPI key.
    -   **AWSPoolID**: Enter your Cognito Identity Pool ID.        

Technologies Used
-----------------

-   **Swift**: The primary language used for development.
-   **AWS Polly**: Used for text-to-speech synthesis to read news articles summary aloud.
-   **SDWebImage**: Used for asynchronous image loading and caching.
-   **Core Data**: Used for caching and local storage.
-   **CocoaPods**: Dependency management for libraries like AWSMobileClient and AWSPolly.

Usage
-----

1.  **Fetching News**: Articles are fetched dynamically based on user scrolling. The app will load articles in batches and cache them for offline viewing.

2.  **Reading Articles Aloud**: Once an article is displayed, users can click on the speaker button to have the article's summary synthesized into speech.

3.  **Dark Mode**: The app adapts its interface for both light and dark mode. Text and background colors will change based on the user's system preference.

Key Components
--------------

### 1\. `FeedViewController`

The `FeedViewController` is responsible for managing the display of news articles. It contains the table view, handles user interactions like scrolling, and triggers the fetching of new articles as the user reaches the end of the list. This controller also interacts with the `FeedViewModel` to fetch and update the articles dynamically.

Key functionalities:

-   Table view setup and configuration.
-   Handles scrolling behavior to fetch new articles dynamically.
-   Updates the UI with fetched articles.
-   Displays errors if any occur during data fetching.

### 2\. `FeedViewModel`

The `FeedViewModel` acts as the intermediary between the `FeedViewController` and the data sources (e.g., network APIs, Core Data). It manages the fetching, processing, and caching of news articles. The view model handles dynamic pagination and ensures that the feed is updated with new articles as the user scrolls. It also manages cache and handles missing data.

Key functionalities:

-   Fetches news articles dynamically from both the cache and the network.
-   Handles pagination and determines the page size based on the user's subscription.
-   Updates the `feedItems` list asynchronously when new data is fetched.
-   Handles errors and updates the UI with appropriate feedback.
-   Is actor-isolated for thread safety in handling `feedItems`.

### 3\. `FeedCell`

The `FeedCell` is a custom table view cell that displays individual news articles. It contains elements like the article's title, description, image thumbnail, and a speaker button for text-to-speech functionality. The cell is designed to be reused efficiently with dynamic content that adjusts based on the data provided.

Key functionalities:

-   Displays the article's title, description, and image.
-   Supports lazy image loading and caching using SDWebImage.
-   Provides a speaker button to trigger text-to-speech functionality (using AWS Polly).
-   Adapts layout based on content size, utilizing `UITableView.automaticDimension` for dynamic cell heights.

### 4\. `ContentSynthesizer`

The `ContentSynthesizer` is responsible for converting the content of articles into speech using AWS Polly. Once a user taps the speaker button on a `FeedCell`, the article's text is sent to AWS Polly, which returns an audio stream that is played back to the user.

Key functionalities:

-   Converts article text to speech using AWS Polly.
-   Manages playback of the synthesized audio.
-   Provides an interface for starting and stopping speech playback.

### 5\. `WebContentExtractor`

`WebContentExtractor` is a utility responsible for extracting clean content from URLs. When a user selects an article, the extractor fetches the raw content (e.g., the article body) from the web page. The cleaned-up content is then passed to the summarizer (OpenAI API) for summarization or directly displayed in the app.

Key functionalities:

-   Fetches and cleans up article content from the web.
-   Integrates with external APIs for content extraction.

### 6\. `SummaryCacheManager`

The `SummaryCacheManager` is used to cache the summarized versions of articles. By caching these summaries, the app avoids re-fetching and re-processing the same content. This improves app performance and provides a faster user experience.

Key functionalities:

-   Caches the summaries for articles to prevent repeated fetches.
-   Retrieves summaries from the cache before fetching new ones.
-   Allows easy management of cached content.

Architecture
------------

The architecture of the News Reader app follows **Clean Architecture** principles along with the **MVVM (Model-View-ViewModel)** pattern. The app emphasizes separation of concerns, scalability, and testability by organizing the code into distinct layers. Additionally, it employs the **Coordinator** pattern to manage the flow and navigation of the app.

### Model

-   **FeedItem:** Represents a single news article with properties such as title, description, image URL, and content. This model is used across different layers of the app to represent articles.
-   **Cache Manager:** A service responsible for managing and retrieving cached articles from **Core Data**, ensuring that previously fetched data is available offline.

### View

-   **FeedViewController:** The main view controller displaying the list of articles. It interacts with the **FeedViewModel**to fetch data and updates the UI accordingly.
-   **FeedCell:** A custom table view cell that displays individual articles with elements like the title, description, image thumbnail, and a speaker button to trigger text-to-speech.

### ViewModel

-   **FeedViewModel:** Acts as an intermediary between the view and the data layers, handling fetching, processing, and updating the UI. It also manages dynamic pagination, caching, and error handling.
-   **ContentSynthesizer:** A ViewModel that is responsible for converting article text into speech using AWS Polly. It isolates the text-to-speech logic from the rest of the app and allows for starting and stopping speech playback.

### Service Layer

-   **OpenAIAPIManager:** A service for interacting with OpenAI's API to summarize article content. After extracting raw content via the **WebContentExtractor**, the summary is sent to OpenAI for processing and returned to the app for display.
-   **FeedService:** A service responsible for handling network requests to fetch articles. It interacts with APIs to fetch articles and integrates with the **CacheManager** to cache articles for offline use.
-   **CacheManager:** Manages caching operations by saving and retrieving articles to and from **Core Data**. It ensures articles are available even when the app is offline.
-   **ContentSynthesizer:** Handles converting text into speech using AWS Polly. It is a service that manages the interaction with AWS and playback functionality for articles.
-   **CoreDataManager:** Responsible for managing interactions with Core Data, handling the saving, retrieving, and deleting of articles and other data entities.

### Coordinator

-   **AppCoordinator:** The root coordinator that manages the initial setup of the app and coordinates the flow to the main feed screen.
-   **FeedCoordinator:** Responsible for managing navigation within the feed section, such as transitioning to article details or managing other transitions.

### Data Flow

1.  **Fetching Data:** The **FeedViewModel** interacts with **FeedService** to fetch articles from a remote API. If no network is available, **CacheManager** retrieves articles from **Core Data**. The **WebContentExtractor** fetches and cleans article content, which is either displayed directly or passed to **OpenAIAPIManager** for summarization.
2.  **Updating the UI:** Once new data is fetched, the **FeedViewModel** updates the **FeedViewController** with the articles, which are then displayed in a table view.
3.  **Handling Errors:** If errors occur during data fetching (e.g., network errors), the **FeedViewModel** handles them and updates the **FeedViewController** with appropriate error messages.
4.  **Text-to-Speech:** When the user taps the speaker button on a **FeedCell**, the **FeedViewModel** communicates with **ContentSynthesizer**, which uses AWS Polly to convert the article text to speech and manage playback.

### Clean Architecture Flow

1.  **Model Layer:** Includes **FeedItem**, **CacheManager**, **FeedService**, **CoreDataManager**, and **OpenAIAPIManager**. These components handle data storage, networking, content extraction, and API calls.
2.  **ViewModel Layer:** The **FeedViewModel** manages data fetching, dynamic pagination, and updates the UI. It interacts with the **ContentSynthesizer** for text-to-speech conversion and uses the **FeedService** for data fetching.
3.  **View Layer:** **FeedViewController** and **FeedCell** manage UI presentation. The view layer listens for updates from the **FeedViewModel** and binds the data to UI elements.
4.  **Service Layer:** The **FeedService**, **OpenAIAPIManager**, **CacheManager**, **ContentSynthesizer**, and **CoreDataManager** provide necessary services like data fetching, content summarization, caching, and text-to-speech functionality. These services are separated from the ViewModel and View, promoting better testability and reusability.
5.  **Coordinator Layer:** The **AppCoordinator** and **FeedCoordinator** manage the app's navigation, decoupling the navigation logic from the view controllers and making the flow more manageable.

The app also supports **asynchronous data fetching** using Swift's concurrency features, ensuring that the UI remains responsive while data is being loaded in the background.

License
-------

This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgements
----------------

-   **AWS Polly** for providing text-to-speech capabilities.
-   **SDWebImage** for providing a powerful image caching and loading library.
-   Thanks to the contributors and open-source community for their continuous support.

Contributing
------------

Feel free to fork this project, submit issues, or open pull requests for improvements! Contributions are always welcome.
