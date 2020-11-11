## Error Reporting

Since the 3scale toolbox is used from scripts / pipelines / etc, any error must be reported without any ambiguity.

## Table of contents
* [Unix Return Code](#unix-return-code)
* [Error Report Fields](#error-report-fields)
* [Error Types](#error-types)
* [Error Code Table](#error-code-table)

### Unix Return Code

If the requested operation cannot be completed, the Unix return code is *1* and if the operation has been completed successfully the Unix return code is *0*.

### Error Report Fields

When an error occurs, the toolbox writes to *stderr* a structured error report with some fields.

```
{
  "code": string,
  "message": string,
  "class": string,
  "stacktrace": array of string
}
```

| Field | Description |
| --- | --- |
| code | Error code. See [table](#error-code-table) |
| message | Description text of the error |
| class | Class of the error |
| stacktrace | (optional) the stacktrace causing the error |

### Error Types

There are three types of errors and the report will depend on the type.

#### Managed Error

The error is managed by the toolbox. This means the error is created by the toolbox in a controlled way.

#### Unmanaged Error

The error is not managed by the toolbox. But still, the error is not a *panic* error.
The application has been able to handle it and generate a detailed report for the user to inspect.
For example, `RuntimeError` or `ZeroDivisionError` are included in this class of errors.

**For this type of errors, the toolbox generates a detailed report in `crash.log` file in the current working directory.**

The assigned error code for this type of errors is `E_UNKNOWN`. See [table](#error-code-table)

#### Unhandled Error

This type of errors are not handled by the toolbox and the error report is delegated to the ruby framework, usually showing stacktrace and error message.
Tipical errors include `NoMemoryErrors`, `SecurityError`, `SignalException` and so on.

### Error Code Table

| Code | Description |
| --- | --- |
| `E_3SCALE` | Generic 3scale Toolbox error |
| `E_3SCALE_API` | 3scale API returned error |
| `E_UNKNOWN` | Unmanaged error |
| `E_INVALID_URL` | Remote URL is not valid |
| `E_ACTIVEDOCS_NOT_FOUND` | Active docs reference can not be found |
| `E_INVALID_ID` | Entity reference is not valid |
