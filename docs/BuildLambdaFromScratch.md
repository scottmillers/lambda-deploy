# How to test and develop AWS lambda functions locally

https://www.youtube.com/watch?v=51EAwBDdgio&t=460s

Steps:

1. mkdir lambda-url-to-html
2. Start a new Node project 
```npm init -y```
3. Download the types for Lambda, Node and esbuild-register which allows you to run typescript code from Node.js
```npm install --save-dev  @types/node @types/aws-lambda esbuild-register```
4. Create a index.ts file and add the following code:
    ```typescript
    import { APIGatewayProxyEventV2, APIGatewayProxyStructuredResultV2 } from 'aws-lambda';

    interface Input {
        url: string;
        name: string;
    }

    interface Output {
        title: string;
        s3_url: string;
    }

    export const handler = async(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyStructuredResultV2> =>
    {
        const body: Output = {
            title: "hello world",
            s3_url: "url goes here",
    };

    return {
        statusCode: 200,
        body: JSON.stringify(body),
    }
    };
    ```

5. Create a file called run.ts to run the Lambda function locally
    ```typescript
    import {handler} from './index';

    const main = async () => {
        const res = await handler({} as any);
        console.log(res);
    };

    main();
    ```
6. Run the code with the esbuild-register to convert the typescript code to javascript
```node -r esbuild-register run.ts```
6. Create a lambda function called lambda-url-to-html
7. Add permission to allow the lambda function to write to S3 (In Terraform)
8. Create an alias called live and point it to $LATEST version (In Terraform)
9. Install [lambda-build](https://github.com/alexkrkn/lambda-build) locally to push your code to the lambda function
```npm install --save-dev lambda-build```
10. Get help for lambda-build
```lambda-build --help```
Lambda build will take any typescript file, bundle it to include any npm dependencies and push it to the lambda function
11.  Run lambda-build
```
$ cd src
$ lambda-build upload -r us-east-1 lambda-url-to-html
 Bundling & Uploading ./index.js|ts
  → Bundle archived 1.31 kB
  → Using region us-east-1
  → Uploading lambda-url-to-html
  ✔ Successfully uploaded lambda-url-to-html
  ✔ Successfully uploaded 1 function(s)
$
``` 
12. Make it easier to deploy by adding a script to package.json
 ```json
"scripts": {
    "deploy" : "lambda-build upload -r us-east-1 lambda-url-to-html"
  },
  ```
13. Deploy again with `npm run deploy`
14. Install a few dependencies
```npm install --save axios cheerio```
Axios is a library that allows you to download web pages. Cheerio is a library that allows you to parse HTML and use CSS selectors to find elements.
15. Change the code in index.ts to use Axios and Cheerio to get the title of the web page
```typescript
import { APIGatewayProxyEventV2, APIGatewayProxyStructuredResultV2 } from 'aws-lambda';
import * as cheerio from 'cheerio';
import axios from 'axios';



interface Input {
    url: string;
    name: string;
}

interface Output {
    title: string;
    s3_url: string;
}

export const handler = async(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyStructuredResultV2> =>
{
    const body: Output = {
        title: "",
        s3_url: "",
    };

    try {

        const body = event.queryStringParameters as unknown as Input;
        const res = await axios.get(body.url);
        output.title = cheerio.load(res.data)(`head > title`).text();

    } catch (err) {
        console.error(err);
    }


    return {
        statusCode: 200,
        body: JSON.stringify(body),
    }
};
```

16. Upload the version using `npm run deploy`
17. Open the AWS Console and create a new version of the lambda function
18. Point the live alias to the new version
19. Test the function through the live alias URL.  In your browser type in the following URL:
```
https://<your lambda function>.execute-api.<your-region>.on.aws/live?url=https://news.ycombinator.com
{
    "title": "Hacker News",
    "s3_url": ""
}
```

20.  Now let's setup unit tests.  Install the following dependencies:
```npm install --save-dev mocha sinon @types/mocha @types/sinon```
21. Create a directory under src called test
22. Create a file called index.test.ts
23. Add the following code to index.ts
```typescript
import { APIGatewayProxyEventV2 } from "aws-lambda";
import {describe, it, afterEach} from `mocha`;
import {handler, Input, Output } from `../index`;



const executeLambda = async (url: string, name: string): Promise<Output | null> => {
    const output = await handler({queryStringParameters: {url, name }});
    let outputBody: Output | null = null;
    if (output) {
        outputBody = JSON.parse(output.body);
    }
    return outputBody;
}

describe('handler', () => {

it('should get the html from a url', async () => {
    const output = await executeLambda("http://example.com",'');
    console.log({output});
})

it('should extract and return the page title of a url', async () => {

})
})
```
24. Add the following code to package.json in the scripts section
```json
"test": "mocha --recursive 'test' --extension ts --exit --require esbuild-register --timeout 20000"
```
25. Run the tests with `npm test`
26. We have a problem.  The tests depend on the http://example.com web site.  That web site might changes. We can use sinon to stub the axion get request.  We can then execute the function and verify the results match what is in the stub.
```typescript

it('should extract and return the page title of a url', async () => {
    const title = "This is the title of example.com";
    stub(axios,"get").resolves({ data: `<html><head><title>${title}</title></head></html>` }) // hijack the call to axios
    const output = await executeLambda("http://example.com",'');
    strictEqual(output.title, title); // verify the results
    //console.log({output});
})

```

27. Now lets add the code to upload the HTML to S3.  Install the following dependencies:
```npm install --save @aws-sdk/client-s3```
28. Update the code in index.ts to upload the HTML to S3
```typescript

import { OutputLocationFilterSensitiveLog, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';

const BUCKET = 'lambda-url-to-html';
const s3Client = new S3Client({region: 'us-east-1'});


export const storage = {

    storeHtmlFile: async (content: string, name: string): Promise<string> => {
        const key = `${name}.html`;
        const command = new PutObjectCommand({
            Bucket: BUCKET,
            Key: key,
            Body: Buffer.from(content),
            ContentType: 'text/html',
        });

        await s3Client.send(command);
        return `https://${BUCKET}.s3.amazonaws.com/${key}`;
    }
}

```

29. Update the unit tests to include the storage handler
30. Deploy the new function code
31. Call your function like before but add a name of the file to store the HTML in S3
```
https://<your lambda function>.execute-api.<your-region>.on.aws/?url=https://news.ycombinator.com&name=hackernews
{
    "title": "Hacker News",
    "s3_url": "https://storage-for-lambda-url-to-html.s3.amazonaws.com/hackernews.html"
}
```
32. View the HTML stored in S3
Open a browser and point to the URL returned in the s3_url field
33. Now lets add a new function to return the HTML from S3.  Create a new file called get.ts
34. Go back to the test file and reset the stubs after each run
```typescript
    afterEach(restore)
```
35. Verify the tests work
36. Create a GitHub action that will:
- Trigger on any changes in the `aws\lambda\usl-to-html\src` directory
- Build the code
- Run the tests
- Deploy the code to the lambda function
The code is in the `.github/workflows/ci.yml` file
37. The code requires you to add the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to the GitHub secrets.  You can get these from the AWS console.







