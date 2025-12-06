<%@ page import="java.sql.*,java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Search Results</title>
</head>
<body>
<h3>Search Results</h3>
<a href="mainPage.jsp">Back to Main Page</a>
<hr />

<%
    String itemType = request.getParameter("itemType");
    if (itemType == null || itemType.trim().isEmpty()) {
        out.println("<p>Please select an item type to search.</p>");
    } else {

        itemType = itemType.trim();   // "tops", "bottoms", "shoes", or "any"

        String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
        String dbUser  = "root";
        String dbPass  = "12345";

        Class.forName("com.mysql.cj.jdbc.Driver");

        // ===================================
        // CASE 1: ANY ITEM TYPE
        // ===================================
        if ("any".equals(itemType)) {
            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
                 Statement st = con.createStatement()) {

                String gender      = request.getParameter("searchGender");
                String size        = request.getParameter("searchSize");
                String color       = request.getParameter("searchColor");
                String description = request.getParameter("searchDescription");
                String condition   = request.getParameter("searchCondition");
                String minPrice    = request.getParameter("searchMinPrice");
                String maxPrice    = request.getParameter("searchMaxPrice");
                String seller      = request.getParameter("searchSeller");

                if (gender != null)      gender      = gender.trim();
                if (size != null)        size        = size.trim();
                if (color != null)       color       = color.trim();
                if (description != null) description = description.trim();
                if (condition != null)   condition   = condition.trim();
                if (minPrice != null)    minPrice    = minPrice.trim();
                if (maxPrice != null)    maxPrice    = maxPrice.trim();
                if (seller != null)      seller      = seller.trim();

                if ("Any Gender".equalsIgnoreCase(gender)) gender = null;
                if ("Any Size".equalsIgnoreCase(size))     size   = null;
                if ("Any Color".equalsIgnoreCase(color))   color  = null;
                if ("Any Seller".equalsIgnoreCase(seller)) seller = null;

                String safeSeller = null;
                if (seller != null && !seller.isEmpty()) {
                    safeSeller = seller.replace("'", "''");
                }

                StringBuilder whereT = new StringBuilder(" WHERE 1=1");
                StringBuilder whereB = new StringBuilder(" WHERE 1=1");
                StringBuilder whereS = new StringBuilder(" WHERE 1=1");

                if (gender != null && !gender.isEmpty()) {
                    String safe = gender.replace("'", "''");
                    whereT.append(" AND t.genderValue = '").append(safe).append("'");
                    whereB.append(" AND b.genderValue = '").append(safe).append("'");
                    whereS.append(" AND s.genderValue = '").append(safe).append("'");
                }
                if (size != null && !size.isEmpty()) {
                    String safe = size.replace("'", "''");
                    whereT.append(" AND t.sizeValue = '").append(safe).append("'");
                    whereB.append(" AND b.sizeValue = '").append(safe).append("'");
                    whereS.append(" AND s.sizeValue = '").append(safe).append("'");
                }
                if (color != null && !color.isEmpty()) {
                    String safe = color.replace("'", "''");
                    whereT.append(" AND t.colorValue = '").append(safe).append("'");
                    whereB.append(" AND b.colorValue = '").append(safe).append("'");
                    whereS.append(" AND s.colorValue = '").append(safe).append("'");
                }
                if (description != null && !description.isEmpty()) {
                    String safeDesc = description.replace("'", "''");
                    whereT.append(" AND t.descriptionValue LIKE '%").append(safeDesc).append("%'");
                    whereB.append(" AND b.descriptionValue LIKE '%").append(safeDesc).append("%'");
                    whereS.append(" AND s.descriptionValue LIKE '%").append(safeDesc).append("%'");
                }
                if (condition != null && !condition.isEmpty()) {
                    String safe = condition.replace("'", "''");
                    whereT.append(" AND t.conditionValue = '").append(safe).append("'");
                    whereB.append(" AND b.conditionValue = '").append(safe).append("'");
                    whereS.append(" AND s.conditionValue = '").append(safe).append("'");
                }
                if (minPrice != null && !minPrice.isEmpty()) {
                    whereT.append(" AND t.minimumBidPriceValue >= ").append(minPrice);
                    whereB.append(" AND b.minimumBidPriceValue >= ").append(minPrice);
                    whereS.append(" AND s.minimumBidPriceValue >= ").append(minPrice);
                }
                if (maxPrice != null && !maxPrice.isEmpty()) {
                    whereT.append(" AND t.minimumBidPriceValue <= ").append(maxPrice);
                    whereB.append(" AND b.minimumBidPriceValue <= ").append(maxPrice);
                    whereS.append(" AND s.minimumBidPriceValue <= ").append(maxPrice);
                }
                if (safeSeller != null) {
                    whereT.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                    whereB.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                    whereS.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                }

                String sqlTops =
                        "SELECT 'tops' AS itemType, t.topIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " t.genderValue AS genderValue, t.sizeValue AS sizeValue, t.colorValue AS colorValue, " +
                                " t.descriptionValue AS descriptionValue, t.conditionValue AS conditionValue, " +
                                " t.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM tops t JOIN users u ON t.auctionSellerIdValue = u.userIdValue" +
                                whereT.toString();

                String sqlBottoms =
                        "SELECT 'bottoms' AS itemType, b.bottomIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " b.genderValue AS genderValue, b.sizeValue AS sizeValue, b.colorValue AS colorValue, " +
                                " b.descriptionValue AS descriptionValue, b.conditionValue AS conditionValue, " +
                                " b.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM bottoms b JOIN users u ON b.auctionSellerIdValue = u.userIdValue" +
                                whereB.toString();

                String sqlShoes =
                        "SELECT 'shoes' AS itemType, s.shoeIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " s.genderValue AS genderValue, s.sizeValue AS sizeValue, s.colorValue AS colorValue, " +
                                " s.descriptionValue AS descriptionValue, s.conditionValue AS conditionValue, " +
                                " s.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM shoes s JOIN users u ON s.auctionSellerIdValue = u.userIdValue" +
                                whereS.toString();

                String finalSql =
                        sqlTops + " UNION ALL " +
                                sqlBottoms + " UNION ALL " +
                                sqlShoes + " ORDER BY itemType, itemId";

                ResultSet rs = st.executeQuery(finalSql);
                boolean found = false;

                while (rs.next()) {
                    found = true;

                    // ==== MINIMAL CHANGE 1: MAKE SELLER CLICKABLE ====
                    String sellerUsername = rs.getString("sellerUsername");
                    String sellerLink =
                            "searchResults.jsp?itemType=any&searchSeller=" +
                                    java.net.URLEncoder.encode(sellerUsername, "UTF-8");
%>

<div style="border:1px solid #ccc; margin:10px; padding:10px;">
    <p><strong>Item Type:</strong> <%= rs.getString("itemType") %></p>

    <p><strong>Seller:</strong>
        <a href="<%= sellerLink %>"><%= sellerUsername %></a>
    </p>

    <p><strong>Gender:</strong> <%= rs.getString("genderValue") %></p>
    <p><strong>Size:</strong> <%= rs.getString("sizeValue") %></p>
    <p><strong>Color:</strong> <%= rs.getString("colorValue") %></p>
    <p><strong>Description:</strong> <%= rs.getString("descriptionValue") %></p>
    <p><strong>Condition:</strong> <%= rs.getString("conditionValue") %></p>
    <p><strong>Price:</strong> $<%= rs.getString("minimumBidPriceValue") %></p>
</div>

<%
        }

        if (!found) {
            out.println("<p>No items found matching your criteria.</p>");
        }

        rs.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }

    // ===================================
    // CASE 2: SINGLE ITEM TYPE
    // ===================================
} else {
    try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
         Statement st = con.createStatement()) {

        String seller = request.getParameter("searchSeller");
        if (seller != null) seller = seller.trim();
        if ("Any Seller".equalsIgnoreCase(seller)) seller = null;
        boolean filterBySeller = (seller != null && !seller.isEmpty());
        String safeSeller = null;
        if (filterBySeller) safeSeller = seller.replace("'", "''");

        String gender      = null;
        String size        = null;
        String color       = null;
        String description = null;
        String condition   = null;

        String frontLen  = null;
        String chestLen  = null;
        String sleeveLen = null;

        String waistLen   = null;
        String inseamLen  = null;
        String outseamLen = null;
        String hipLen     = null;
        String riseLen    = null;

        String minPrice = request.getParameter("searchMinPrice");
        String maxPrice = request.getParameter("searchMaxPrice");

        if ("tops".equals(itemType)) {
            gender      = request.getParameter("searchTopGender");
            size        = request.getParameter("searchTopSize");
            color       = request.getParameter("searchTopColor");
            frontLen    = request.getParameter("searchTopFrontLength");
            chestLen    = request.getParameter("searchTopChestLength");
            sleeveLen   = request.getParameter("searchTopSleeveLength");
            description = request.getParameter("searchTopDescription");
            condition   = request.getParameter("searchTopCondition");
        } else if ("bottoms".equals(itemType)) {
            gender      = request.getParameter("searchBottomGender");
            size        = request.getParameter("searchBottomSize");
            color       = request.getParameter("searchBottomColor");
            waistLen    = request.getParameter("searchBottomWaistLength");
            inseamLen   = request.getParameter("searchBottomInseamLength");
            outseamLen  = request.getParameter("searchBottomOutseamLength");
            hipLen      = request.getParameter("searchBottomHipLength");
            riseLen     = request.getParameter("searchBottomRiseLength");
            description = request.getParameter("searchBottomDescription");
            condition   = request.getParameter("searchBottomCondition");
        } else if ("shoes".equals(itemType)) {
            gender      = request.getParameter("searchShoeGender");
            size        = request.getParameter("searchShoeSize");
            color       = request.getParameter("searchShoeColor");
            description = request.getParameter("searchShoeDescription");
            condition   = request.getParameter("searchShoeCondition");
        }

        if (gender != null)      gender      = gender.trim();
        if (size != null)        size        = size.trim();
        if (color != null)       color       = color.trim();
        if (frontLen != null)    frontLen    = frontLen.trim();
        if (chestLen != null)    chestLen    = chestLen.trim();
        if (sleeveLen != null)   sleeveLen   = sleeveLen.trim();
        if (waistLen != null)    waistLen    = waistLen.trim();
        if (inseamLen != null)   inseamLen   = inseamLen.trim();
        if (outseamLen != null)  outseamLen  = outseamLen.trim();
        if (hipLen != null)      hipLen      = hipLen.trim();
        if (riseLen != null)     riseLen     = riseLen.trim();
        if (description != null) description = description.trim();
        if (condition != null)   condition   = condition.trim();
        if (minPrice != null)    minPrice    = minPrice.trim();
        if (maxPrice != null)    maxPrice    = maxPrice.trim();

        if ("Any Gender".equalsIgnoreCase(gender)) gender = null;
        if ("Any Size".equalsIgnoreCase(size))     size   = null;
        if ("Any Color".equalsIgnoreCase(color))   color  = null;

        String tableAlias = "i";
        StringBuilder sql =
                new StringBuilder("SELECT " + tableAlias + ".*, u.usernameValue AS sellerUsername " +
                        "FROM " + itemType + " " + tableAlias +
                        " JOIN users u ON " + tableAlias + ".auctionSellerIdValue = u.userIdValue" +
                        " WHERE 1=1");

        if (gender != null && !gender.isEmpty()) {
            String safe = gender.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".genderValue = '").append(safe).append("'");
        }
        if (size != null && !size.isEmpty()) {
            String safe = size.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".sizeValue = '").append(safe).append("'");
        }
        if (color != null && !color.isEmpty()) {
            String safe = color.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".colorValue = '").append(safe).append("'");
        }

        if ("tops".equals(itemType)) {
            if (frontLen != null && !frontLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".frontLengthValue = ").append(frontLen);
            }
            if (chestLen != null && !chestLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".chestLengthValue = ").append(chestLen);
            }
            if (sleeveLen != null && !sleeveLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".sleeveLengthValue = ").append(sleeveLen);
            }
        }

        if ("bottoms".equals(itemType)) {
            if (waistLen != null && !waistLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".waistLengthValue = ").append(waistLen);
            }
            if (inseamLen != null && !inseamLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".inseamLengthValue = ").append(inseamLen);
            }
            if (outseamLen != null && !outseamLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".outseamLengthValue = ").append(outseamLen);
            }
            if (hipLen != null && !hipLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".hipLengthValue = ").append(hipLen);
            }
            if (riseLen != null && !riseLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".riseLengthValue = ").append(riseLen);
            }
        }

        if (description != null && !description.isEmpty()) {
            String safeDesc = description.replace("'", "''");
            sql.append(" AND ").append(tableAlias)
                    .append(".descriptionValue LIKE '%").append(safeDesc).append("%'");
        }
        if (condition != null && !condition.isEmpty()) {
            String safe = condition.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".conditionValue = '").append(safe).append("'");
        }
        if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND ").append(tableAlias).append(".minimumBidPriceValue >= ").append(minPrice);
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND ").append(tableAlias).append(".minimumBidPriceValue <= ").append(maxPrice);
        }

        if (filterBySeller && safeSeller != null) {
            sql.append(" AND u.usernameValue = '").append(safeSeller).append("'");
        }

        ResultSet rs = st.executeQuery(sql.toString());
        boolean found = false;

        String idCol = null;
        if ("tops".equals(itemType)) {
            idCol = "topIdValue";
        } else if ("bottoms".equals(itemType)) {
            idCol = "bottomIdValue";
        } else if ("shoes".equals(itemType)) {
            idCol = "shoeIdValue";
        }

        while (rs.next()) {
            found = true;

            // ==== MINIMAL CHANGE 2: MAKE SELLER CLICKABLE ====
            String sellerUsername = rs.getString("sellerUsername");
            String sellerLink =
                    "searchResults.jsp?itemType=any&searchSeller=" +
                            java.net.URLEncoder.encode(sellerUsername, "UTF-8");
%>

<div style="border:1px solid #ccc; margin:10px; padding:10px;">
    <% if (idCol != null) { %>
    <p><strong>Item ID:</strong> <%= rs.getString(idCol) %></p>
    <% } %>

    <p><strong>Seller:</strong>
        <a href="<%= sellerLink %>"><%= sellerUsername %></a>
    </p>

    <p><strong>Gender:</strong> <%= rs.getString("genderValue") %></p>
    <p><strong>Size:</strong> <%= rs.getString("sizeValue") %></p>
    <p><strong>Color:</strong> <%= rs.getString("colorValue") %></p>
    <p><strong>Description:</strong> <%= rs.getString("descriptionValue") %></p>
    <p><strong>Condition:</strong> <%= rs.getString("conditionValue") %></p>
    <p><strong>Price:</strong> $<%= rs.getString("minimumBidPriceValue") %></p>
</div>

<%
                }

                if (!found) {
                    out.println("<p>No items found matching your criteria.</p>");
                }

                rs.close();
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
            }
        }
    }
%>

</body>
</html>
