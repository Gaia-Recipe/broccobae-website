# Simple PowerShell HTTP Server
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8080/')
$listener.Start()
Write-Host 'Server started at http://localhost:8080/'
Write-Host 'Press Ctrl+C to stop the server'

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq '/') {
            $localPath = '/index.html'
        }
        
        $filePath = Join-Path (Get-Location) $localPath.TrimStart('/')
        
        if (Test-Path $filePath) {
            $extension = [System.IO.Path]::GetExtension($filePath)
            switch ($extension) {
                '.html' { $response.ContentType = 'text/html' }
                '.css' { $response.ContentType = 'text/css' }
                '.js' { $response.ContentType = 'application/javascript' }
                '.png' { $response.ContentType = 'image/png' }
                '.jpg' { $response.ContentType = 'image/jpeg' }
                '.jpeg' { $response.ContentType = 'image/jpeg' }
                '.gif' { $response.ContentType = 'image/gif' }
                '.svg' { $response.ContentType = 'image/svg+xml' }
                default { $response.ContentType = 'text/plain' }
            }
            
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
            $errorContent = [System.Text.Encoding]::UTF8.GetBytes('404 - File Not Found')
            $response.ContentLength64 = $errorContent.Length
            $response.OutputStream.Write($errorContent, 0, $errorContent.Length)
        }
        
        $response.Close()
    }
} finally {
    $listener.Stop()
    Write-Host 'Server stopped'
}