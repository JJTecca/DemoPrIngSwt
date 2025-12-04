<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Internship Platform</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 40px;
            background-color: #f0f0f0;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        h1 {
            color: #007bff;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px;
            font-weight: bold;
        }
        .btn:hover {
            background: #0056b3;
        }
        .info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: left;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>🏢 Internship Platform</h1>
    <p>Database Integration Test</p>

    <div class="info">
        <p><strong>Test Database Connection:</strong></p>
        <p>This will test if the StudentInfoBean can connect to the database and retrieve records.</p>
    </div>

    <a href="${pageContext.request.contextPath}/Students" class="btn">
        🧪 Test Students Page
    </a>

    <div style="margin-top: 30px; color: #666;">
        <p><strong>Server Time:</strong> <%= new java.util.Date() %></p>
        <p><strong>Context Path:</strong> ${pageContext.request.contextPath}</p>
    </div>

    <a href="${pageContext.request.contextPath}/InternshipPos" class="btn">
        🧪 Test Internship Positions Page
    </a>

    <div style="margin-top: 30px; color: #666;">
        <p><strong>Server Time:</strong> <%= new java.util.Date() %></p>
        <p><strong>Context Path:</strong> ${pageContext.request.contextPath}</p>
    </div>
</div>
</body>
</html>