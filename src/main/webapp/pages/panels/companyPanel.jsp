<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Company Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <div class="card">
        <div class="card-header bg-primary text-white">
            <h3>Company Dashboard</h3>
        </div>
        <div class="card-body">
            <h4>Welcome, Company Representative!</h4>
            <p>Email: ${sessionScope.userEmail}</p>
            <p>Role: ${sessionScope.userRole}</p>
            <a href="${pageContext.request.contextPath}/UserLogin" class="btn btn-primary">Back to Login</a>
        </div>
    </div>
</div>
</body>
</html>