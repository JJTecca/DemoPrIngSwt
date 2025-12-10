<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Faculty Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <div class="card">
        <div class="card-header bg-info text-white">
            <h3>Faculty Dashboard</h3>
        </div>
        <div class="card-body">
            <h4>Welcome, Faculty Member!</h4>
            <p>Email: ${sessionScope.userEmail}</p>
            <p>Role: ${sessionScope.userRole}</p>
            <a href="${pageContext.request.contextPath}/UserLogin" class="btn btn-primary">Back to Login</a>
        </div>
    </div>
</div>
</body>
</html>