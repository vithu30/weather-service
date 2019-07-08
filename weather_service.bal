import ballerina/http;
import ballerina/log;
import ballerinax/docker;
import ballerina/mime;
import ballerina/math;
import ballerina/time;

final string SOAP_NAMESPACE ="http://www.w3.org/2003/05/soap-envelope";
final string SOAP12_CONTENT_TYPE = "application/soap+xml";

@docker:Expose {}
listener http:Listener weatherForecastEP = new(9090);

@docker:Config {

    name: "weatherforecast",

    tag: "v1.0"
}

@http:ServiceConfig {
    basePath: "/weather"
}
service weatherForecast on weatherForecastEP {
    @http:ResourceConfig {
        methods: ["POST"]
    }
    resource function getWeather(http:Caller caller, http:Request request) {
        http:Response response = new;
        if (request.hasHeader("Content-Type")) {
            string baseType = getBaseType(request.getContentType());
            if (baseType == SOAP12_CONTENT_TYPE) {
                int temperature = math:randomInRange(30, 40);
                int humidity = math:randomInRange(70, 80);
                xml|error requestPayload = request.getXmlPayload();
                if (requestPayload is xml) {
                    xml soapBody = requestPayload.*;
                    string location = soapBody.GetWeather.CityName.getTextValue();
                    int t = location.length();
                    if (location.length() != 0) {
                        xml responsePayload = xml `<m0:getWeatherResponse xmlns:m0="http://services.samples">
                                                      <m0:WeatherResult>
                                                          <m0:Location>${location}</m0:Location>
                                                          <m0:Temperature>${temperature}</m0:Temperature>
                                                          <m0:RelativeHumidity>${humidity}</m0:RelativeHumidity>
                                                      </m0:WeatherResult>
                                                   </m0:getWeatherResponse>`;
                        response.setXmlPayload(creatSoapResponse(responsePayload), contentType=SOAP12_CONTENT_TYPE);
                        var result = caller->respond(response);
                        if (result is error) {
                            log:printError("Error sending response", err = result);
                        }
                    } else {
                        xml faultResponse = xml `<Fault>
                                                      <faultcode>SOAP-ENV:Client</faultcode>
                                                      <faultstring>Required attribute is missing</faultstring>
                                                 </Fault>`;
                        response.setXmlPayload(creatSoapResponse(faultResponse), contentType=SOAP12_CONTENT_TYPE);
                        var result = caller->respond(response);
                        if (result is error) {
                            log:printError("Error sending response", err = result);
                        }
                    }
                } else {
                    xml faultResponse = xml `<Fault>
                                                  <faultcode>SOAP-ENV:Client</faultcode>
                                                  <faultstring>Unsupported Media Type</faultstring>
                                             </Fault>`;
                    response.setXmlPayload(creatSoapResponse(faultResponse), contentType=SOAP12_CONTENT_TYPE);
                    var result = caller->respond(response);
                    if (result is error) {
                        log:printError("Error sending response", err = result);
                    }
                }
                
            } else {
                xml faultResponse = xml `<Fault>
                                              <faultcode>SOAP-ENV:Client</faultcode>
                                              <faultstring>Unsupported Media Type</faultstring>
                                         </Fault>`;
                response.setXmlPayload(creatSoapResponse(faultResponse), contentType=SOAP12_CONTENT_TYPE);
                var result = caller->respond(response);
                if (result is error) {
                    log:printError("Error sending response", err = result);
                }
            }
        } else {
            xml faultResponse = xml `<Fault>
                                          <faultcode>SOAP-ENV:Client</faultcode>
                                          <faultstring>Unsupported Media Type</faultstring>
                                     </Fault>`;
            response.setXmlPayload(creatSoapResponse(faultResponse), contentType=SOAP12_CONTENT_TYPE);
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }
    
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/*"
    }
    resource function sendGetResponse(http:Caller caller, http:Request request) {
        string response = "Successful Invocation!";
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}

# Returns base type from content type
#
# + contentType - content type sent in request
# + return - base type of the content type
function getBaseType(string contentType) returns string {
    var result = mime:getMediaType(contentType);
    if (result is mime:MediaType) {
        return result.getBaseType();
    } else {
        panic result;
    }
}

# Creates the SOAP response.
#
# + responsePayload - The payload to be sent
# + return - XML with the SOAP envelope
function creatSoapResponse(xml responsePayload) returns xml {
    xml soapResponse = createSoapEnvelop(SOAP_NAMESPACE);
    soapResponse.setChildren(createSoapBody(responsePayload, SOAP_NAMESPACE));
    return soapResponse;
}

# Provides an empty SOAP envelope
#
# + namespace - The SOAP namespace of SOAP12
# + return - XML with the empty SOAP envelope
function createSoapEnvelop(string namespace) returns xml {
    return xml `<soap:Envelope
                     xmlns:soap="${namespace}">
                </soap:Envelope>`;
}

# Provides the SOAP body in the request as XML.
#
# + payload - The payload to be sent
# + namespace - The SOAP namespace of SOAP12
# + return - XML with the SOAP body
function createSoapBody(xml payload, string namespace) returns xml {
    xml bodyRoot = xml `<soap:Body
                             xmlns:soap="${namespace}">
                        </soap:Body>`;
    bodyRoot.setChildren(payload);
    return bodyRoot;
}
