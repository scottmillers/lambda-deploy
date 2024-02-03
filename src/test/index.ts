import { APIGatewayProxyEventV2 } from "aws-lambda";
import {describe, it, afterEach} from "mocha";
import {handler, Input, Output, storage } from "../index";
import {stub, restore} from "sinon";
import axios from "axios";
import { strictEqual } from "assert";



const executeLambda = async (url: string, name: string): Promise<Output | null> => {
    const output = await handler({queryStringParameters: {url, name }});
    let outputBody: Output | null = null;
    if (output) {
        outputBody = JSON.parse(output.body);
    }
    return outputBody;
};

const s3UrlFile = 'https://s3fileurl.com'
const title = "This is the title of example.com";

afterEach(restore); // restore the stubs after each call

describe('handler', () => {

it('should get the html from a url', async () => {
    const name = `file_name`;

    stub(axios,"get").resolves({ data: `<html><head><title>${title}</title></head></html>` }); // hijack the call to axios get
    stub(storage, 'storeHtmlFile').resolves(s3UrlFile); //hijack the call for the return url
    
    const output = await executeLambda("http://example.com",name);
    
    strictEqual(output.s3_url, s3UrlFile); // verify the results
});

it('should extract and return the page title of a url', async () => {
    const name = `file_name`;
    const html = `<html><head><title>${title}</title></head></html>`;

    stub(axios, 'get').resolves({data: html}); // mock the get call to return html
    
    const storeHtmlStub = stub(storage, `storeHtmlFile`).resolves(s3UrlFile); // mock the s3 storage
    
    const output = await executeLambda("http://example.com",name);
  

    strictEqual(output.title, title); // verify the title
    strictEqual(storeHtmlStub.calledOnceWith(html, name), true); // verify the storage is called  
})



})